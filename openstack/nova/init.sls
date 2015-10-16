{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/nova/map.jinja" import nova_settings with context %}

openstack_nova:
  pkg.installed:
    - pkgs: {{ nova_settings.packages|yaml }}

  group.present:
    - name: {{ nova_settings.group }}
    - system: True
    - require:
        - pkg: openstack_nova

  user.present:
    - name: {{ nova_settings.user }}
    - system: True
    - gid: {{ nova_settings.group }}
    - home: {{ nova_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_nova
        - group: openstack_nova

  file.recurse:
    - name: {{ nova_settings.config_directory }}
    - source: salt://openstack/nova/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ nova_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_nova
        - group: openstack_nova
        - user: openstack_nova

  cmd.wait:
    - name: nova-manage db sync
    - user: {{ nova_settings.user }}
    - watch:
        - pkg: openstack_nova
        - group: openstack_nova
        - user: openstack_nova
        - file: openstack_nova

  service.running:
    - names: {{ nova_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_nova
        - group: openstack_nova
        - user: openstack_nova
        - file: openstack_nova
        - cmd: openstack_nova
