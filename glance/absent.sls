{% from "openstack/release.jinja" import openstack_release with context %}
{% from "glance/map.jinja" import glance_settings with context %}

openstack_image_absent:
  service.dead:
    - names: {{ glance_settings.services|yaml }}
    - enable: False

  {% if glance_settings.purge %}
  pkg.purged:
  {% else %}
  pkg.removed:
  {% endif %}
    - pkgs: {{ glance_settings.packages|yaml }}
    - require:
        - service: openstack_image_absent

  {% if glance_settings.purge %}
  file.absent:
    - name: {{ glance_settings.config_directory }}
    - require:
        - pkg: openstack_image_absent
  {% endif %}

  user.absent:
    - name: {{ glance_settings.user }}
    - force: True
    - purge: {{ glance_settings.purge }}
    - require:
        - pkg: openstack_image_absent

  group.absent:
    - name: {{ glance_settings.group }}
    - require:
        - user: openstack_image_absent
