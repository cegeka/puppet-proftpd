--
-- Create table ftplog, logs can be stored here
--
CREATE TABLE IF NOT EXISTS `ftplog` (
  `id` int(11) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `transfertime` varchar(10) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `pid` int(11) NOT NULL,
  `size` varchar(15) NOT NULL,
  `command` varchar(40) NOT NULL,
  `options` text NOT NULL,
  `filename` text NOT NULL,
  `username` varchar(16) NOT NULL,
  `returncode` int(11) NOT NULL,
  `protocol` varchar(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `username` (`username`),
  KEY `protocol` (`protocol`),
  KEY `command` (`command`)
);

--
-- Create table ftp_group, groups can be stored here
--
CREATE TABLE IF NOT EXISTS `ftp_group` (
  `groupname` varchar(16) NOT NULL default '',
  `gid` int(7) NOT NULL default 65534,
  `members` varchar(16) NOT NULL default '',
  PRIMARY KEY (`groupname`),
  UNIQUE KEY `groupname` (`groupname`)
);

--
-- Create table ftp_users, users can be stored here
--
CREATE TABLE IF NOT EXISTS `ftp_users` (
  `id` int(11) NOT NULL auto_increment,
  `customer` int(11) NOT NULL default 1,
  `userid` varchar(255) NOT NULL,
  `realname` varchar(32) NOT NULL default '',
  `shell` varchar(20) NOT NULL default '/sbin/nologin',
  `passwd` varchar(255) NOT NULL default '!!',
  `active` char(1) NOT NULL default 'Y',
  `uid` int(11) NOT NULL default '101',
  `gid` int(11) NOT NULL default '65534',
  `home` varchar(255) NOT NULL default '/home/catchall',
  `lastchange` varchar(50) NOT NULL default '',
  `deleted` varchar(1) NOT NULL default 'N',
  `delchange` datetime NOT NULL default CURRENT_TIMESTAMP,
  `ftp` varchar(10) NOT NULL default 'false',
  `sftp` varchar(10) NOT NULL default 'true',
  `ftps` varchar(10) NOT NULL default 'false',
  `migrated` tinyint(1) NOT NULL default 1,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `userid` (`userid`)
);

CREATE TABLE IF NOT EXISTS `sftp_hostkeys` (
  `host` varchar(255) NOT NULL,
  `sshkey` varchar(255) NOT NULL,
  KEY `sftphostkeys_idx` (`host`)
);

--
-- Table for sFTP user keys, similar to authorized_key
--
CREATE TABLE IF NOT EXISTS `sftp_userkeys` (
  `id` int(11) NOT NULL auto_increment,
  `customer` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sshkey` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sftpuserkeys_idx` (`name`)
);

--
-- Create the proftp group with group id 65534
--
INSERT INTO `ftp_group` (
  groupname, gid
  ) VALUES ('proftp',65534);

--
-- Create a dummy user with SHA-512 encoded password
--  Most values will default to the table defaults, edit where needed!
--  Use this for demonstration purpose only, don't put this in production!
--
INSERT INTO `ftp_users` (userid,realname,passwd) values ('dummy','My first dummy user','$6$uCpTpX0HWrDjF14d$FMFS73l1C/.5jc3gtve5Px3AGUAZ0mssvmJ6kpvSk3xAhXZU8D1qopr4EoyHhIlucGdrHAPGzYUkJ2v0FqHrF/');
