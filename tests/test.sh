#!/bin/bash

DATASCIENCE_TESTDIR=$TESTDIR/datascience-notebook
if ! jupyter nbconvert --execute "${DATASCIENCE_TESTDIR}/datascience_notebook.ipynb"; then
    echo "Integration test failed"
    echo "could not execute datascience_notebook"
    exit 1
fi

if ! test -f "${DATASCIENCE_TESTDIR}/datascience_notebook.html"; then
    echo "Integration test failed"
    echo "Compiled datascience_notebook.html does not exist"
    exit 1
fi

echo "datascience-notebook integration test passed!"