# 2.1.0
* Support ERB tags in config files.

# 2.0.0
* Upgrade to txgh-server 3.0 to conform to new Transifex auth strategy.

# 1.1.0
* Retry on network errors from Net::Protocol and Faraday.

# 1.0.2
* Don't fail if the txgh response code is in the 300 range (304 returned when a Transifex payload specifies a language equal to the source language).

# 1.0.1
* Fetch config correctly when processing jobs (used to only work for github repos).

# 1.0.0
* Birthday!