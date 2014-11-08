MESOS_MASTER_OPTS=--name mesos-master \
	--link zookeeper:zookeeper \
	-p 5050:5050 \
	-e MESOS_QUORUM=1 \
	-e MESOS_ZK=zk://zookeeper:2181/mesos \
	-e MESOS_WORK_DIR=/var/lib/mesos

MESOS_SLAVE_OPTS=--name mesos-slave \
	--privileged \
	--link zookeeper:zookeeper \
	-e MESOS_MASTER=zk://zookeeper:2181/mesos \
	-e MESOS_CONTAINERIZERS="docker,mesos" \
	-e MESOS_EXECUTOR_REGISTRATION_TIMEOUT="5mins"

MARATHON_OPTS=--name marathon \
	--link zookeeper:zookeeper \
	-p 8080:8080

MARATHON_CMD=/opt/marathon/bin/start --master zk://zookeeper:2181/mesos --zk_hosts zookeeper:2181 --task_launch_timeout 300000

build:
	docker build -t choko/mesos mesos/
	docker build -t choko/mesos-master mesos-master/
	docker build -t choko/mesos-slave mesos-slave/
	docker build -t choko/marathon marathon/
	docker build -t choko/zookeeper zookeeper/

pull:
	docker pull choko/zookeeper
	docker pull choko/marathon
	docker pull choko/mesos-master
	docker pull choko/mesos-slave

run:
	docker run --name zookeeper -d choko/zookeeper
	docker run ${MESOS_MASTER_OPTS} -d choko/mesos-master
	docker run ${MARATHON_OPTS} -d choko/marathon ${MARATHON_CMD}
	docker run ${MESOS_SLAVE_OPTS} -d choko/mesos-slave

stop:
	docker rm `docker kill -s 9 zookeeper mesos-master mesos-slave marathon`