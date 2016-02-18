{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/repo/map.jinja" import openstack_repo_settings with context %}

openstack_repo_absent:
  pkg.purged:
    - pkgs: {{ openstack_repo_settings.packages|yaml }}

  {% if salt['grains.get']('os_family') == 'Debian' %}
  pkgrepo.absent:
    {% if openstack_repo_settings.url %}
    - name: {{ openstack_repo_settings.url }}
    {% else %}
    - name: deb {{ openstack_repo_settings.url_prefix }} {{ salt['grains.get']('oscodename') }}-updates/{{ openstack_release }} main
    {% endif %}
    - require_in:
        - pkg: openstack_repo_absent

  {% elif salt['grains.get']('os_family') == 'RedHat' %}
  file.absent:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-{{ openstack_release|title }}
    - require_in:
        - pkg: openstack_repo_absent
  pkgrepo.absent:
    - name: rdo-release
    - require_in:
        - pkg: openstack_repo_absent

  {% elif salt['grains.get']('os_family') == 'Suse' %}
  module.run:
    - name: zypper.del_repo
    - repo: {{ openstack_release|title }}
    - require_in:
        - pkg: openstack_repo_absent
  {% endif %}
