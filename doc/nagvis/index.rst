======================
Nagvis Configuring Overview
======================

Nagvis is the most advanced mapping module. It is both flexible, scalable and consider the under cards. Nagvis will help make connections between cards, insert background images, icons or pictures ..

Prerequisites
=========

To create or edit maps you need Visio diagram as design software . To upload file you need to connect securely to the shared resources  on the server ( Ex. Bitvise TBM ) . This tool allows accessing remote files over an encrypted connection as if they were files on a local drive, without requiring SFTP or SCP file transfers.

Create a map
=========

The map must be like on the model below :

Integration of the map in Nagvis
=========
Opne Bitvise. The diagrams are stored in /usr/local/NagVis/share/userfiles/images/maps/

Create the map in Nagvis
=========

Go to Otions Menu / Manage maps
In Create a map complete the field as follows :

+ Map Name ( site_name )
+ Map icon : std_small
+ Background Map . Select from the pull down menu, the map you just downloaded on the Linux server MAP_Name.png .

 Adding elements to map 
 =========
 
 Now that we have our map , we have to add elements to our map .
We already have a default panel item with Nagvis :

+ Icon
+ Line
+ Special

The icons and lines offer us to link the item you will choose :

+	A host
+	A service
+ A group of hosts ( hostgroup in Naemon )
+ A service group ( servicegroup in Naemon )
+ A map (icon summarizing the overall status of the card and serving as a link to there )

We will add two elements to our map : service and host. To add proceed as follows:
In the Edit menu a map / icon Add / Host
A window opens the Create Object. In the host_name field, select the server name and confirm your choice by clicking on the "Save" button. The mouse pointer changes to a + sign , select the server to modify.

You can unlock the object added , while clicking , support and move the object. To enable this feature , go to the menu Edit Map , Select Lock / Unlock All. Go to the Edit Map manu / Add icon / Service

A window opens **Create Object**. In the host_name field, select the server name , then in the service_description field, select the service name and confirm your choice by clicking on the "Save" button. The mouse pointer changes to a + sign , click on the server to modify.

Modify Object
 =========
select the MAP you want to modify. Move your mouse to the object you want to change , once in edit mode :


+ Modify : In the case you have to change to the server name.
+ Delete : If you delete the server or stop his monitoring.
