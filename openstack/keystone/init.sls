{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/keystone/map.jinja" import keystone_settings with context %}

openstack_keystone:
  pkg.installed:
    - pkgs: {{ keystone_settings.packages|yaml }}

  group.present:
    - name: keystone
    - system: True
    - require:
        - pkg: openstack_keystone

  user.present:
    - name: {{ keystone_settings.user }}
    - system: True
    - gid: {{ keystone_settings.group }}
    - home: 
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_keystone
        - group: openstack_keystone

  file.recurse:
    - name: {{ keystone_settings.config_directory }}
    - source: salt://openstack/keystone/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ keystone_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_keystone
        - group: openstack_keystone
        - user: openstack_keystone

  cmd.wait:
    - name: keystone-manage db_sync
    - user: {{ keystone_settings.user }}
    - watch:
        - pkg: openstack_keystone
        - group: openstack_keystone
        - user: openstack_keystone
        - file: openstack_keystone

  service.running:
    - names: {{ keystone_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_keystone
        - group: openstack_keystone
        - user: openstack_keystone
        - file: openstack_keystone
        - cmd: openstack_keystone

  cron.present:
    - name: chronic keystone-manage token_flush
    - user: keystone
    - minute: random
    - require:
        - user: openstack_keystone
        - service: openstack_keystone
