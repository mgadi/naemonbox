============
Time periods
============

********** 
Description
**********

A time period is a list of times during various days that are considered to be "valid" times for notifications and service checks. It consists of time ranges for each day of the week that "rotate" once the week has come to an end.

Different types of exceptions to the normal weekly time are supported, including: specific weekdays, days of generic months, days of specific months, and calendar dates.

Time periods apply to two types of actions:

* Execution of  check commands
* Sending of notifications

*************
Configuration
*************

The configuration of time periods is done in the menu: **Config Tool ==> Object Configuration ==> Timeperiods ==> Create a new timeperiod**.

Basic options 
=============

* The **Time period name** and **Alias** fields define the name and description of the time period respectively.
* The fields belonging to the **Time range** sub-category define the days of the week for which it is necessary to define time periods.
* The **Exceptions** table enables us to include days excluded from the time period.

Syntax of a time period
=======================

When creating a time period, the following characters serve to define the time periods :

* The character “:” separates the hours from the minutes. E.g.: HH:MM
* The character “-” indicates continuity between two time periods
* The character ”,” serve s to separate two time periods

Here are a few examples:

* 24 hours a day and 7 days a week: 00:00-24:00 (to be applied on every day of the week).
* From 08h00 to 12h00 and from 14h00 to 18h45 (to be applied on weekdays only).
