{% from "openstack/release.jinja" import openstack_release with context %}
{% from "keystone/map.jinja" import keystone_settings with context %}

openstack_keystone:
  pkg.installed:
    - pkgs: {{ keystone_settings.packages|yaml }}

  group.present:
    - name: {{ keystone_settings.group }}
    - system: True
    - require:
        - pkg: openstack_keystone

  user.present:
    - name: {{ keystone_settings.user }}
    - system: True
    - gid: {{ keystone_settings.group }}
    - home: {{ keystone_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_keystone
        - group: openstack_keystone

  file.recurse:
    - name: {{ keystone_settings.config_directory }}
    - source: salt://keystone/files/{{ openstack_release }}/
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
    - user: {{ keystone_settings.user }}
    - minute: random
    - require:
        - user: openstack_keystone
        - service: openstack_keystone

{% set keystone_connection_args = [
    'keystone.user',
    'keystone.password',
    'keystone.tenant',
    'keystone.tenant_id',
    'keystone.auth_url',
    'keystone.token',
    'keystone.endpoint',
  ] %}

{% for tenant in keystone_settings.tenants %}
{{ 'openstack_keystone_tenant_%s'|format(tenant.name if tenant is mapping else tenant)|yaml_encode }}:
  keystone.tenant_present:
  {% if tenant is mapping %}
    - name: {{ tenant.name|yaml_encode }}
    {% if tenant.description is defined %}
    - description: {{ tenant.description|yaml_encode }}
    {% endif %}
    {% if tenant.enabled is defined %}
    - enabled: {{ True if tenant.enabled else False }}
    {% endif %}
    {% for connection_arg in keystone_connection_args if tenant[connection_arg] is defined %}
    - {{ connection_arg|yaml_encode }}: {{ tenant[connection_arg]|yaml_encode }}
    {% else %}
      {% if tenant.profile is defined %}
    - profile: {{ tenant.profile|yaml_encode }}
      {% elif keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
      {% endif %}
    {% endfor %}
  {% else %}
    - name: {{ tenant|yaml_encode }}
    {% if keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
    {% endif %}
  {% endif %}
    - require:
        - service: openstack_keystone
{% endfor %}

{% for role in keystone_settings.roles %}
{{ 'openstack_keystone_role_%s'|format(role.name if role is mapping else role)|yaml_encode }}:
  keystone.role_present:
  {% if role is mapping %}
    - name: {{ role.name|yaml_encode }}
    {% for connection_arg in keystone_connection_args if role[connection_arg] is defined %}
    - {{ connection_arg|yaml_encode }}: {{ role[connection_arg]|yaml_encode }}
    {% else %}
      {% if role.profile is defined %}
    - profile: {{ role.profile|yaml_encode }}
      {% elif keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
      {% endif %}
    {% endfor %}
  {% else %}
    - name: {{ role|yaml_encode }}
    {% if keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
    {% endif %}
  {% endif %}
    - require:
        - service: openstack_keystone
{% endfor %}

{% for user in keystone_settings.users %}
  {# These are dictionaries (mappings) because then we don't have to
   # worry about duplicate entries. #}
  {% set required_tenants = {} %}
  {% set required_roles = {} %}
{{ 'openstack_keystone_user_%s'|format(user.name)|yaml_encode }}:
  keystone.user_present:
    - name: {{ user.name|yaml_encode }}
    - password: {{ user.password|yaml_encode }}
    - email: {{ user.email|yaml_encode }}
    {% if user.tenant is defined %}
      {% do required_tenants.update({user.tenant: True}) %}
    - tenant: {{ user.tenant|yaml_encode }}
    {% endif %}
    {% if user.enabled is defined %}
    - enabled: {{ True if user.enabled else False }}
    {% endif %}
    {% if user.roles is defined and user.roles is mapping %}
      {# Iterate over the tenant/role assignments. #}
      {% for tenant, roles in user.roles|dictsort %}
        {% do required_tenants.update({tenant: True}) %}
        {% for role in roles %}
          {% do required_roles.update({role: True}) %}
        {% endfor %}
      {% endfor %}
    - roles: {{ user.roles|yaml }}
    {% endif %}
    {% for connection_arg in keystone_connection_args if user[connection_arg] is defined %}
    - {{ connection_arg|yaml_encode }}: {{ user[connection_arg]|yaml_encode }}
    {% else %}
      {% if user.profile is defined %}
    - profile: {{ user.profile|yaml_encode }}
      {% elif keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
      {% endif %}
    {% endfor %}
    - require:
        - service: openstack_keystone
    {% for tenant, ignored_value in required_tenants|dictsort %}
        - keystone: {{ 'openstack_keystone_tenant_%s'|format(tenant)|yaml_encode }}
    {% endfor %}
    {% for role, ignored_value in required_roles|dictsort %}
        - keystone: {{ 'openstack_keystone_role_%s'|format(role)|yaml_encode }}
    {% endfor %}
{% endfor %}

{% for service in keystone_settings.service_catalog %}
{{ 'openstack_keystone_service_%s'|format(service.name)|yaml_encode }}:
  keystone.service_present:
    - name: {{ service.name|yaml_encode }}
    - service_type: {{ service.service_type|yaml_encode }}
  {% if service.description is defined %}
    - description: {{ service.description|yaml_encode }}
  {% endif %}
  {% for connection_arg in keystone_connection_args if service[connection_arg] is defined %}
    - {{ connection_arg|yaml_encode }}: {{ service[connection_arg]|yaml_encode }}
  {% else %}
    {% if service.profile is defined %}
    - profile: {{ service.profile|yaml_encode }}
    {% elif keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
    {% endif %}
  {% endfor %}
{% endfor %}

{% for endpoint in keystone_settings.endpoints %}
{{ 'openstack_keystone_endpoint_%s'|format(endpoint.name)|yaml_encode }}:
  keystone.endpoint_present:
    - name: {{ endpoint.name|yaml_encode }}
  {% if endpoint.publicurl is defined %}
    - publicurl: {{ endpoint.publicurl|yaml_encode }}
  {% endif %}
  {% if endpoint.internalurl is defined %}
    - internalurl: {{ endpoint.internalurl|yaml_encode }}
  {% endif %}
  {% if endpoint.adminurl is defined %}
    - adminurl: {{ endpoint.adminurl|yaml_encode }}
  {% endif %}
  {% if endpoint.region is defined %}
    - region: {{ endpoint.region|yaml_encode }}
  {% endif %}
  {% for connection_arg in keystone_connection_args if endpoint[connection_arg] is defined %}
    - {{ connection_arg|yaml_encode }}: {{ endpoint[connection_arg]|yaml_encode }}
  {% else %}
    {% if endpoint.profile is defined %}
    - profile: {{ endpoint.profile|yaml_encode }}
    {% elif keystone_settings.profile %}
    - profile: {{ keystone_settings.profile }}
    {% endif %}
  {% endfor %}
{% endfor %}
