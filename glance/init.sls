{% from "openstack/release.jinja" import openstack_release with context %}
{% from "glance/map.jinja" import glance_settings with context %}

openstack_glance:
  pkg.installed:
    - pkgs: {{ glance_settings.packages|yaml }}

  group.present:
    - name: {{ glance_settings.group }}
    - system: True
    - require:
        - pkg: openstack_glance

  user.present:
    - name: {{ glance_settings.user }}
    - system: True
    - gid: {{ glance_settings.group }}
    - home: {{ glance_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_glance
        - group: openstack_glance

  file.recurse:
    - name: {{ glance_settings.config_directory }}
    - source: salt://glance/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ glance_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_glance
        - group: openstack_glance
        - user: openstack_glance

  cmd.wait:
    - name: glance-manage db_sync
    - user: {{ glance_settings.user }}
    - watch:
        - pkg: openstack_glance
        - group: openstack_glance
        - user: openstack_glance
        - file: openstack_glance

  service.running:
    - names: {{ glance_settings.services|yaml }}
    - enable: True
    - watch:
        - pkg: openstack_glance
        - group: openstack_glance
        - user: openstack_glance
        - file: openstack_glance
        - cmd: openstack_glance
