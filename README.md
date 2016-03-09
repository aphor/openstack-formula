# openstack-formula

This Salt state formula installs and configures
[OpenStack](http://openstack.org/), a free and open-source cloud
computing software platform.

## Available States

* **openstack.repo**

  Activates the OpenStack-specific package repositories on SUSE Linux
  Enterprise Server, Red Hat Enterprise Linux, or Ubuntu.

* **keystone**

  Installs and configures the OpenStack Identity service; provisions
  tenants, roles, and users; and registers other OpenStack services
  and their API endpoints in the service catalog.

* **glance**

  Installs and configures the OpenStack Image service, including the
  API endpoint and store drivers.

* **nova.conductor**

  Installs and configures an OpenStack Compute Controller node.  Note
  that this defaults to legacy networking.

* **nova**

  Installs and configures an OpenStack Compute node.  Note that this
  defaults to legacy networking.

* **neutron.server**

  Installs and configures an OpenStack Networking Controller node;
  manages both the virtual networking infrastructure (VNI) and
  physical networking infrastructure (PNI); and provisions network
  toplogies including firewalls, load balancers, and virtual private
  networks (VPNs).

* **neutron**

  Installs and configures an OpenStack Networking Network node, which
  handles internal and external routing and DHCP services for virtual
  networks.

* **nova.network**

  Installs and configures OpenStack Neutron for Compute nodes.  One
  must also override the configuration of the `nova.conductor` and
  `nova` states, which use legacy networking by default.

* **horizon**

  TODO

* **cinder**

  TODO

* **cinder.volume**

  TODO

* **swift.proxy**

  TODO

* **swift**

  TODO

* **heat**

  TODO

* **ceilometer**

  TODO

### Removing OpenStack

Each state listed above has a cooresponding `.absent` state that
undoes the corresponding set of changes.  For example, to remove the
OpenStack Identity service, use the `keystone.absent` state.

## Configuration

TODO

## Other Formulas

* [ntp-formula](https://github.com/saltstack-formulas/ntp-formula)

  Servers participating in an OpenStack deployment should have their
  clocks synchronized using the Network Time Protocol (NTP).

* [epel-formula](https://github.com/saltstack-formulas/epel-formula)

  When deploying OpenStack on computers running Red Hat Enterprise
  Linux or a related distribution, the
  [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL)
  (EPEL) repository must be enabled.

* [rabbitmq-formula](https://github.com/saltstack-formulas/rabbitmq-formula)

  OpenStack components communicate with one another using a message
  broker such as RabbitMQ.  The message broker usually runs on the
  controller node.

* [hbase-formula](https://github.com/dwyerk/hbase-formula) (telemetry
  only; requires
  [hadoop-formula](https://github.com/saltstack-formulas/hadoop-formula)),
  [mongodb-formula](https://github.com/saltstack-formulas/mongodb-formula)
  (telemetry only),
  [mysql-formula](https://github.com/saltstack-formulas/mysql-formula),
  [postgres-formula](https://github.com/saltstack-formulas/postgres-formula),
  or
  [saltstack-elasticsearch-formula](https://github.com/bechtoldt/saltstack-elasticsearch-formula)
  (telemetry events only)

  OpenStack uses a relational database to store configuration data or
  other information about its services.  Typically, the controller
  node hosts this database.  OpenStack supports
  [MySQL](https://www.mysql.com/), [MariaDB](https://mariadb.org/) (a
  community-developed fork of MySQL), and
  [PostgreSQL](https://www.postgresql.org/).

  OpenStack Telemetry also uses a database to record metering data
  pertaining to the Compute, Image, Block Storage, and Object Storage
  services.  It supports [HBase](http://hbase.apache.org/),
  [MongoDB](https://www.mongodb.org/), MySQL/MariaDB, and PostgreSQL,
  and it includes partial support for
  [ElasticSearch](https://www.elastic.co/).

* [memcached-formula](https://github.com/saltstack-formulas/memcached-formula),
  [redis-formula](https://github.com/saltstack-formulas/redis-formula),
  or
  [zookeeper-formula](https://github.com/saltstack-formulas/zookeeper-formula),

  OpenStack Telemtry polling agents and notification agents can run in
  an HA deployment using an in-memory key-value store (KVS).
  [Tooz](https://pypi.python.org/pypi/tooz), the library underlying
  this capability, supports [memcached](http://memcached.org/),
  [Redis](http://redis.io/), and
  [ZooKeeper](http://zookeeper.apache.org/).

* [django-formula](https://github.com/saltstack-formulas/django-formula)

  TODO

* [apache-formula](https://github.com/saltstack-formulas/apache-formula)
  or
  [nginx-formula](https://github.com/saltstack-formulas/nginx-formula)

  TODO
