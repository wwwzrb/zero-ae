#!/bin/bash

kill -2 $(pidof redis-server)
kill -9 $(pidof agent_worker)
