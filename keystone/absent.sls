{% from "openstack/release.jinja" import openstack_release with context %}
{% from "keystone/map.jinja" import keystone_settings with context %}

openstack_identity_absent:
  service.dead:
    - names: {{ keystone_settings.services|yaml }}
    - enable: False

  cron.absent:
    - name: chronic keystone-manage token_flush
    - user: {{ keystone_settings.user }}
    - identifier: openstack_identity

  {% if keystone_settings.purge %}
  pkg.purged:
  {% else %}
  pkg.removed:
  {% endif %}
    - pkgs: {{ keystone_settings.packages|yaml }}
    - require:
        - service: openstack_identity_absent
        - cron: openstack_identity_absent

  {% if keystone_settings.purge %}
  file.absent:
    - name: {{ keystone_settings.config_directory }}
    - require:
        - pkg: openstack_identity_absent
  {% endif %}

  user.absent:
    - name: {{ keystone_settings.user }}
    - force: True
    - purge: {{ keystone_settings.purge }}
    - require:
        - pkg: openstack_identity_absent

  group.absent:
    - name: {{ keystone_settings.group }}
    - require:
        - user: openstack_identity_absent
