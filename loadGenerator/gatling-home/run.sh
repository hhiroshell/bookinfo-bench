#!/bin/sh

USERS=10
DURATION=30
CONCURRENCY_PER_LB=2
DESCRIPTION="LBs=$(cat ./endpoints.txt | wc -l) | concurrency-per-lb=$CONCURRENCY_PER_LB | users=$USERS | duration=$DURATION"
TIMESTAMP=`date '+%y-%m-%d_%H-%M-%S'`

echo "------------- Parameters -------------"
echo USERS=$USERS
echo DURATION=$DURATION
echo CONCURRENCY_PER_LB=$CONCURRENCY_PER_LB
echo DESCRIPTION=$DESCRIPTION
echo TIMESTAMP=$TIMESTAMP
echo "--------------------------------------"

echo "--------- startd: $TIMESTAMP ---------"

mkdir -p ./results/$TIMESTAMP

while read LB
do
    for i
    in `seq 1 $CONCURRENCY_PER_LB`
    do
        JAVA_OPTS="-Dusers=$USERS -Dduring=$DURATION -DbaseUrl=$LB" \
        ./bin/gatling.sh \
            --simulation bookinfo_bench.IncreaseAndDecreaseUsers \
            --run-description "$DESCRIPTION" \
            --no-reports \
            --results-folder ./results/$TIMESTAMP \
            &
    done
done < ./endpoints.txt
wait

pushd ./results/$TIMESTAMP
for result in `ls`; do
    mkdir report 2>/dev/null
    cp ${result}/simulation.log ./report/${result}.log
done
popd

./bin/gatling.sh --reports-only $TIMESTAMP/report

echo "------------- Parameters -------------"
echo USERS=$USERS
echo DURATION=$DURATION
echo CONCURRENCY_PER_LB=$CONCURRENCY_PER_LB
echo DESCRIPTION=$DESCRIPTION
echo TIMESTAMP=$TIMESTAMP
echo "--------------------------------------"

echo "-------- finished: $TIMESTAMP --------"