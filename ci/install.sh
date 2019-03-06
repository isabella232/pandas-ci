echo "inside $0"

echo "Running ${JOB}"

if [ "$JOB" == "ASV" ]; then

    echo "[building asv]"
    time conda build pandas/conda.recipe/meta.yaml --python=3.7 --numpy=1.14

    echo "[installing asv]"
    time conda install -n pandas --use-local pandas

elif [ "$JOB" == "PIP" ]; then

    source activate pandas

    pushd pandas

    echo "[patching]"
    wget https://github.com/pandas-dev/pandas/pull/25568.patch -O - | git apply -

    echo "[building dist]"
    time bash scripts/build_dist_for_release.sh || exit 1

    echo "[create fresh environment]":
    conda create -n pip-test-env python=3.7 -yq
    source activate pip-test-env
    echo "[pip-test-env before]"
    conda list

    echo "[pip install]"
    time pip install dist/*tar.gz || exit 1

    popd

elif [ "$JOB" == "CONDA" ]; then

    echo "[build conda]"
    time conda build pandas/conda.recipe/meta.yaml --python=3.7 --numpy=1.14

    echo "[install conda]"
    time conda install -n pandas --use-local pandas

fi
