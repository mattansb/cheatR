# cheatR NEWS

This doc details user-facing changes only.

## Version 1.2.0

### Breaking Changes

- `catch_em()` now returns a matrix, and not a list.
- Plotting now removes lonely nodes (nodes that are not related to any other node). This can be changed by setting `remove_lonely = FALSE`.

## Version 1.0.0-5

| Function | Update | Notes |
|---------:|:-------|:------|
|`graph_em`| NEW | Plots a graph between the similarity scores. |
| `print`, `summary`, `hist` | NEW | New methods for class `chtrs`. |

## Version 1.0.0

| Function | Update | Notes |
|---------:|:-------|:------|
|`catch_em`| IMPROVEMENT | Function now accounts for auto-similarities between docs, making similarity estimates more precise (previous estimates where slightly skewed upwards) |