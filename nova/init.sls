{% from "openstack/release.jinja" import openstack_release with context %}
{% from "nova/map.jinja" import nova_settings with context %}

openstack_compute:
  pkg.installed:
    - pkgs: {{ nova_settings.packages|yaml }}

  group.present:
    - name: {{ nova_settings.group }}
    - system: True
    - require:
        - pkg: openstack_compute

  user.present:
    - name: {{ nova_settings.user }}
    - system: True
    - gid: {{ nova_settings.group }}
    - home: {{ nova_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_compute
        - group: openstack_compute

  file.recurse:
    - name: {{ nova_settings.config_directory }}
    - source: salt://nova/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ nova_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_compute
        - group: openstack_compute
        - user: openstack_compute
