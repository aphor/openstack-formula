{% from "openstack/release.jinja" import openstack_release with context %}
{% from "glance/map.jinja" import glance_settings with context %}

openstack_image:
  pkg.installed:
    - pkgs: {{ glance_settings.packages|yaml }}

  group.present:
    - name: {{ glance_settings.group }}
    - system: True
    - require:
        - pkg: openstack_image

  user.present:
    - name: {{ glance_settings.user }}
    - system: True
    - gid: {{ glance_settings.group }}
    - home: {{ glance_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_image
        - group: openstack_image

  file.recurse:
    - name: {{ glance_settings.config_directory }}
    - source: salt://glance/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ glance_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_image
        - group: openstack_image
        - user: openstack_image

  cmd.wait:
    - name: glance-manage db_sync
    - user: {{ glance_settings.user }}
    - watch:
        - pkg: openstack_image
        - group: openstack_image
        - user: openstack_image
        - file: openstack_image

  service.running:
    - names: {{ glance_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_image
        - group: openstack_image
        - user: openstack_image
        - file: openstack_image
        - cmd: openstack_image
