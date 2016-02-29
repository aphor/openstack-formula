{% from "openstack/release.jinja" import openstack_release with context %}
{% from "nova/map.jinja" import nova_compute_settings with context %}

openstack_nova_compute:
  pkg.installed:
    - pkgs: {{ nova_compute_settings.packages|yaml }}

  group.present:
    - name: {{ nova_compute_settings.group }}
    - system: True
    - require:
        - pkg: openstack_nova_compute

  user.present:
    - name: {{ nova_compute_settings.user }}
    - system: True
    - gid: {{ nova_compute_settings.group }}
    - home: {{ nova_compute_settings.home_directory }}
    - password: '*'
    - shell: /bin/false
    - require:
        - pkg: openstack_nova_compute
        - group: openstack_nova_compute

  file.recurse:
    - name: {{ nova_compute_settings.config_directory }}
    - source: salt://nova/compute/files/{{ openstack_release }}/
    - template: jinja
    - user: root
    - group: {{ nova_compute_settings.group }}
    - dir_mode: 751
    - file_mode: 640
    - require:
        - pkg: openstack_nova_compute
        - group: openstack_nova_compute
        - user: openstack_nova_compute
