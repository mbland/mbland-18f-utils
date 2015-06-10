## `tick.rb`

Filters Tock project hours by user.

### Usage

First, grab the value of the `_oauthproxy` cookie. In Chrome, you can access
the [chrome://settings/cookies](cookies settings), search for the `18f.gov`
cookie, click on the `_oauthproxy` value and copy the value of the `Content:`
field.

Then run:

```shell
$ OAUTH_COOKIE=[value of _oauthproxy cookie] \
  tick.rb YYYY-MM-DD[,...] project_name[,...]
```

Where:

- `YYYY-MM-DD[,...]`: matches one or more comma-separated timestamps
  corresponding to Tock reporting dates
- `project_name[,...]`: corresponds to one or more comma-separarated project
  names as stored in Tock

You can see the [`burn.rb`](./burn.rb) script for an example of how to wrap
the [`tick.rb`](./tick.rb) script to avoid dealing with a monster command
line.

### Sample output

```shell
$ OAUTH_COOKIE=[value of _oauthproxy cookie]
  tick.rb \
  2015-05-17,2015-05-24,2015-05-31 \
  "18F Hub,18F Guides" 2>&1 | tee burn.txt

*** 2015-05-17 ***
  --- 18F Hub ---
    aidan.feldman@gsa.gov  4.50
    michael.bland@gsa.gov 30.00
  --- 18F Guides ---
    michael.bland@gsa.gov  1.00
*** 2015-05-24 ***
  --- 18F Guides ---
    michael.bland@gsa.gov  0.50
  --- 18F Hub ---
    michael.bland@gsa.gov 23.00
    aidan.feldman@gsa.gov  4.00
*** 2015-05-31 ***
  --- 18F Guides ---
    michael.bland@gsa.gov  3.00
  --- 18F Hub ---
    michael.bland@gsa.gov 25.00
    aidan.feldman@gsa.gov  2.00
    michelle.hertzfeld@gsa.gov  1.00
    colin.macarthur@gsa.gov  1.03
```
