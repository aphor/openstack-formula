# openstack-formula

This Salt state formula installs and configures OpenStack, a free and
open-source cloud computing software platform.

## Required Formulas

* [epel-formula](https://github.com/saltstack-formulas/epel-formula)

  Several parts of this formula rely on packages found the
  [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL)
  (EPEL) repository.  When deploying OpenStack on computers running
  Red Hat Enterprise Linux or a related distribution, make sure to
  also enable the EPEL repository.

* [mysql-formula](https://github.com/saltstack-formulas/mysql-formula)
  or
  [postgres-formula](https://github.com/saltstack-formulas/postgres-formula)

  OpenStack uses a SQL database to store configuration data or other
  information about its services.  Typically, one installs this
  database on the controller node.  OpenStack supports both MySQL and
  PostgreSQL.

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

  Installs and configures the OpenStack Identity service, including
  tenants, users, roles, and the service entity and API endpoint.

## Configuration

TODO
