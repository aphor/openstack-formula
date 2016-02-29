{% from "openstack/release.jinja" import openstack_release with context %}
{% from "nova/conductor/map.jinja" import nova_conductor_settings with context %}

openstack_nova_conductor:
  pkg.installed:
    - pkgs: {{ nova_conductor_settings.packages|yaml }}

  group.present:
    - name: {{ nova_conductor_settings.group }}
    - system: True
    - require:
        - pkg: openstack_nova_conductor

  user.present:
    - name: {{ nova_conductor_settings.user }}
    - system: True
    - gid: {{ nova_conductor_settings.group }}
    - home: {{ nova_conductor_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_nova_conductor
        - group: openstack_nova_conductor

  file.recurse:
    - name: {{ nova_conductor_settings.config_directory }}
    - source: salt://openstack/nova/conductor/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ nova_conductor_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_nova_conductor
        - group: openstack_nova_conductor

  cmd.wait:
    - name: nova-manage db sync
    - user: {{ nova_conductor_settings.user }}
    - watch:
        - pkg: openstack_nova_conductor
        - file: openstack_nova_conductor

  service.running:
    - names: {{ nova_conductor_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_nova_conductor
        - group: openstack_nova_conductor
        - user: openstack_nova_conductor
        - file: openstack_nova_conductor
        - cmd: openstack_nova_conductor
