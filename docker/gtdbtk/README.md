# gtdbtk

## Test

```sh
docker run --rm -v /gtdbtk/data/path:/db --env GTDBTK_DATA_PATH=/db gtdbtk \
    gtdbtk test --out_dir ~/gtdbtk checkm_test_results
```