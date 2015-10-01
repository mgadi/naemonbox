======================
Introduction
======================
One of the features of Naemon' object configuration format is that you can create object definitions that inherit properties from other object definitions.

.. Tip::
   Also, read up on the object tricks that offer shortcuts for otherwise tedious configuration tasks.    
..

.. Note::
   When creating and/or editing configuration files, keep the following in mind:
    1. Lines that start with a '#' character are taken to be comments and are not processed
    2. Directive names are case-sensitive
    3. Characters that appear after a semicolon (;) in configuration lines are treated as comments and are not processed
..

An explanation of how object inheritance works can be found `here`_.

.. _here: http://www.naemon.org/documentation/usersguide/objectinheritance.html

I strongly suggest that you familiarize yourself with object inheritance once you read over the documentation presented `there`_, as it will make the job of creating and maintaining object definitions much easier than it otherwise would be.

Now it is time to create some configuration object definitions in order to monitor a new Windows machine. We will start by creating a basic host group for all Windows machines for one site.

.. _there: http://www.naemon.org/documentation/usersguide/objectdefinitions.html
