# SUN-1 aggregate tracking analysis

This folder contains an R script used to analyse the movement of SUN-1 aggregates in live imaging experiments.

After in vivo imaging of SUN-1 aggregates, image stacks are first aligned in ImageJ. Individual aggregates are then tracked manually or semi-manually in ImageJ, and the tracking results are exported as an Excel table. The Excel file is subsequently analysed in RStudio with the script provided here.

This workflow was used for SUN-1 aggregate dynamics analysis following live imaging experiments related to SUN-1 aggregate behaviour in *C. elegans* meiotic nuclei.

## Suggested file name

`sun1_aggregate_tracking_dynamics_analysis.R`

## Workflow overview

1. Acquire live-imaging stacks of SUN-1 aggregates in vivo.
2. Align image stacks in ImageJ to correct for sample drift.
3. Track SUN-1 aggregates in ImageJ.
4. Export tracking coordinates to Excel.
5. Open the R script in RStudio and load the Excel file when prompted.
6. Compute trajectory plots, explored area, speed, total distance, split/fusion events, and residency-time related summaries.

## Input

The script expects an Excel file selected interactively with `file.choose()`.

The table should contain at least the following columns:

- `t`: time point index
- `d`: aggregate ID / track ID
- `x`: x coordinate
- `y`: y coordinate

Each aggregate should have a unique identifier in `d`, and time points should be encoded consistently across tracks.

## What the script does

The script:

- reads the Excel tracking table
- reorganizes coordinates by track ID
- recenters all trajectories relative to the first tracked aggregate
- plots aggregate trajectories
- estimates the explored area of each trajectory using a convex hull
- calculates frame-to-frame speed
- calculates average speed per aggregate
- estimates total travelled distance
- derives a simple split/fusion summary from changes in detected tracks over time
- computes a residency-time related distribution based on persistence across frames

## Output

The current script mainly produces results in the R session and plotting window:

- trajectory plots
- trajectory plots with convex hull outlines
- numeric variables generated in memory, including:
  - `area`
  - `speed`
  - `average_speed`
  - `tot_dist`
  - `split_fusion`
  - `time_for_distri`

At present, the script does **not** automatically save plots or write output tables to disk.

## Required R packages

The script uses the following packages:

- `geometry`
- `readxl`
- `matlab`
- `pracma`
- `dismo`

Install them in R if needed:

```r
install.packages(c("geometry", "readxl", "matlab", "pracma", "dismo"))
```

## Notes and assumptions

- The script uses a pixel scaling factor of `107.8` and a time interval of `5` between frames in the speed calculation.
- Speed is calculated from Euclidean displacement between consecutive frames.
- The first aggregate is used as the positional reference for alignment of all trajectories.
- Convex hull calculation can fail for problematic tracks with too few valid points or degenerate geometries; the script handles this by assigning `NA`.
- The workflow assumes that stack alignment and tracking quality were checked beforehand in ImageJ.
