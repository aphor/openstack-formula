# openstack-formula

This Salt state formula installs and configures
[OpenStack](http://openstack.org/), a free and open-source cloud
computing software platform.

## Required Formulas

* [epel-formula](https://github.com/saltstack-formulas/epel-formula)

  When deploying OpenStack on computers running Red Hat Enterprise
  Linux or a related distribution, the
  [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL)
  (EPEL) repository must be enabled.

* [mysql-formula](https://github.com/saltstack-formulas/mysql-formula)
  or
  [postgres-formula](https://github.com/saltstack-formulas/postgres-formula)

  OpenStack uses a SQL database to store configuration data or other
  information about its services.  Typically, the controller node
  hosts this database.  OpenStack supports both MySQL and PostgreSQL.

* [rabbitmq-formula](https://github.com/saltstack-formulas/rabbitmq-formula)

  OpenStack components communicate with one another using a message
  broker such as RabbitMQ.  The message broker usually runs on the
  controller node.

* [apache-formula](https://github.com/saltstack-formulas/apache-formula)

  TODO

## Available States

* **openstack.repo**

  Activates the OpenStack-specific package repositories on SUSE
  Enterprise Linux, Red Hat Enterprise Linux, or Ubuntu.

* **openstack.keystone**

  Installs and configures the OpenStack Identity service; provisions
  tenants, roles, and users; and registers other OpenStack services
  and their API endpoints in the service catalog.

* **openstack.glance**

  Installs and configures the OpenStack Image service, including the
  API endpoint and store drivers.

* **openstack.nova.controller**

  Deploys an OpenStack Compute controller node.

* **openstack.nova.compute**

  Deploys an OpenStack Compute hypervisor node.

* **openstack.nova.network**

* **openstack.nova**

  Installs and configures both the OpenStack Compute controller and
  hypervisor services on the same node, in that order (not recommended
  for use in production environments).

### Removing OpenStack

Each state listed above has a cooresponding `.absent` state that
undoes the corresponding set of changes.  For example, to remove the
OpenStack Identity service, use the `openstack.keystone.absent` state.

## Configuration

TODO
