# Indices

This file maintains a list of the xclim/climpact indices required for CCAM evaluation.

List of xclim indices: https://xclim.readthedocs.io/en/stable/indicators.html

List of climpact indices: https://github.com/ARCCSS-extremes/climpact/blob/master/www/user_guide/Climpact_user_guide.md#appendixa

Please use the following table to track the metrics coded and what is still left to do.

(Note: view raw to see markdown table formatting.)

### Temperature indices
| Index | Description | xclim | Climpact | Notes |
| - | - | - | - | - |
| txn | Coldest daily maximum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| txx | Warmest daily maximum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| txm | Mean daily maximum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| tx10p | Percentage of days when daily maximum temperature is less than 10th percentile | :heavy_check_mark: | :heavy_check_mark: | - |
| tx90p | Percentage of days when daily maximum temperature is greater than 90th percentile | :heavy_check_mark: | :heavy_check_mark: | - |
| tnn | Coldest daily minimum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| tnx | Warmest daily minimum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| tnm | Mean daily minimum temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| tn10p | Percentage of days when daily minimum temperature is less than 10th percentile | :heavy_check_mark: | :heavy_check_mark: | - |
| tn90p | Percentage of days when daily minimum temperature is greater than 90th percentile | :heavy_check_mark: | :heavy_check_mark: | - |
| tmm | Mean daily mean temperature | :heavy_check_mark: | :heavy_check_mark: | - |
| dtr | Daily temperature range | :heavy_check_mark: | :heavy_check_mark: | - |
| hwn | Heatwave number | :heavy_check_mark: | :heavy_check_mark: | Defined as 'heat wave frequency' in xclim. xclim uses absolute values, climpact uses 90th percentile or excess heat factor |
| hwf | Heatwave frequency | - | :heavy_check_mark: | - |
| hwd | Heatwave duration | :heavy_check_mark: | :heavy_check_mark: | Defined as 'heat wave max length' in xclim |
| hwm | Heatwave magnitude | - | :heavy_check_mark: | - |
| hwa | Heatwave amplitude | - | :heavy_check_mark: | - |

### Rainfall indices
| Index | Description | xclim | Climpact | Notes |
| - | - | - | - | - |
| rx1day | Maximum 1 day precipitation | :heavy_check_mark: | :heavy_check_mark: | - |
| rx5day | Maximum 5 day precipitation | :heavy_check_mark: | :heavy_check_mark: | Some differences between xclim & climpact due to centering of 5-day period |
| r10mm | Number of days when rainfall is greater than or equal to 10mm | :heavy_check_mark: | :heavy_check_mark: | - |
| r20mm | Number of days when rainfall is greater than or equal to 20mm | :heavy_check_mark: | :heavy_check_mark: | - |
| r95p | Amount of rainfall from very wet days  | :heavy_check_mark: | :heavy_check_mark: | - |
| r99p | Amount of rainfall from extremely wet days  | :heavy_check_mark: | :heavy_check_mark: | - |
| r95ptot | Fraction of total wet-day rainfall that comes from very wet days | :heavy_check_mark: | :heavy_check_mark: | - |
| r99ptot | Fraction of total wet-day rainfall that comes from extremely wet days | :heavy_check_mark: | :heavy_check_mark: | - |
| prcptot | Total precipitation | :heavy_check_mark: | :heavy_check_mark: | - |
| cdd | Consecutive Dry Days | :heavy_check_mark: | :heavy_check_mark: | - |
| cwd | Consecutive Wet Days | :heavy_check_mark: | :heavy_check_mark: | - |
| sdii | Average daily wet-day rainfall intensity | :heavy_check_mark: | :heavy_check_mark: | - |

... and so on.
