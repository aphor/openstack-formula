{% from "openstack/release.jinja" import openstack_release with context %}
{% from "openstack/keystone/map.jinja" import keystone_settings with context %}

openstack_keystone_absent:
  service.dead:
    - names: {{ keystone_settings.services|yaml }}
    - enable: False

  cron.absent:
    - name: chronic keystone-manage token_flush
    - user: {{ keystone_settings.user }}
    - identifier: openstack_keystone

  {% if keystone_settings.purge %}
  pkg.purged:
  {% else %}
  pkg.removed:
  {% endif %}
    - pkgs: {{ keystone_settings.packages|yaml }}
    - require:
        - service: openstack_keystone_absent
        - cron: openstack_keystone_absent

  {% if keystone_settings.purge %}
  file.absent:
    - name: {{ keystone_settings.config_directory }}
    - require:
        - pkg: openstack_keystone_absent
  {% endif %}

  user.absent:
    - name: {{ keystone_settings.user }}
    - force: True
    - purge: {{ keystone_settings.purge }}
    - require:
        - pkg: openstack_keystone_absent

  group.absent:
    - name: {{ keystone_settings.group }}
    - require:
        - user: openstack_keystone_absent
