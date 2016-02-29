{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/repo/map.jinja" import openstack_repo_settings with context %}

openstack_repo:
  pkg.installed:
    - pkgs: {{ openstack_repo_settings.packages|yaml }}

  {% if salt['grains.get']('os_family') == 'Debian' %}
  pkgrepo.managed:
    {% if openstack_repo_settings.url %}
    - name: {{ openstack_repo_settings.url }}
    {% else %}
    - name: deb {{ openstack_repo_settings.url_prefix }} {{ salt['grains.get']('oscodename') }}-updates/{{ openstack_release }} main
    {% endif %}
    - file: /etc/apt/sources.list.d/cloudarchive-{{ openstack_release }}.list
    - require:
        - pkg: openstack_repo

  {% elif salt['grains.get']('os_family') == 'RedHat' %}
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-{{ openstack_release|title }}
    - source: salt://openstack/repo/files/RPM-GPG-KEY-RDO-{{ openstack_release|title }}
  cmd.wait:
    - name: rpm -import /etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-{{ openstack_release|title }}
    - watch:
        - file: openstack_repo
  pkgrepo.managed:
    - name: rdo-release
    - humanname: OpenStack {{ openstack_release|title }} Repository
    {% if openstack_repo_settings.url %}
    - baseurl: {{ openstack_repo_settings.url }}
    {% else %}
      {# emulates logic of the rdo-release post-install script #}
      {% if salt['grains.get']('os') == 'Fedora' %}
        {% set dist = 'fedora' %}
      {% else %}
        {% set dist = 'epel' %}
      {% endif %}
      {% set releasever = salt['grains.get']('osmajorrelease') %}
    - baseurl: {{ openstack_repo_settings.url_prefix }}/openstack-{{ openstack_release }}/{{ dist }}-{{ releasever }}/
    {% endif %}
    - gpgcheck: 1
    - gpgfile: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-{{ openstack_release|title }}
    - require:
        - pkg: openstack_repo
        - cmd: openstack_repo

  {% elif salt['grains.get']('os_family') == 'Suse' %}
  module.run:
    - name: zypper.mod_repo
    - repo: {{ openstack_release|title }}
    {% if openstack_repo_settings.url %}
    - url: {{ openstack_repo_settings.url }}
    {% else %}
    - url: {{ openstack_repo_settings.url_prefix }}:{{ openstack_release|title }}/{{ "SLE" if salt['grains.get']('os') == 'SUSE' else "openSUSE" }}_{{ salt['grains.get']('osrelease').replace(' ', '_') }}
    {% endif %}
    - require:
        - pkg: openstack_repo
  {% endif %}
