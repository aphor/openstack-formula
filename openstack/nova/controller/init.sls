{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/nova/controller/map.jinja" import nova_controller_settings with context %}

openstack_nova_controller:
  pkg.installed:
    - pkgs: {{ nova_controller_settings.packages|yaml }}

  group.present:
    - name: {{ nova_controller_settings.group }}
    - system: True
    - require:
        - pkg: openstack_nova_controller

  user.present:
    - name: {{ nova_controller_settings.user }}
    - system: True
    - gid: {{ nova_controller_settings.group }}
    - home: {{ nova_controller_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_nova_controller
        - group: openstack_nova_controller

  file.recurse:
    - name: {{ nova_controller_settings.config_directory }}
    - source: salt://openstack/nova/controller/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ nova_controller_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_nova_controller
        - group: openstack_nova_controller
        - user: openstack_nova_controller

  cmd.wait:
    - name: nova-manage db sync
    - user: {{ nova_controller_settings.user }}
    - watch:
        - pkg: openstack_nova_controller
        - group: openstack_nova_controller
        - user: openstack_nova_controller
        - file: openstack_nova_controller

  service.running:
    - names: {{ nova_controller_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_nova_controller
        - group: openstack_nova_controller
        - user: openstack_nova_controller
        - file: openstack_nova_controller
        - cmd: openstack_nova_controller
