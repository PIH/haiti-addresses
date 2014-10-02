drop table if exists cnigs;

CREATE table cnigs (
  cnigs_id int(11) NOT NULL AUTO_INCREMENT,
  departement varchar(255),
  arrondissement varchar(255),
  commune varchar(255),
  section varchar(255),
  localitie varchar(255),
  source varchar(255),
  fid_1 int(11),
  lat_x double,
  long_y double,
  PRIMARY KEY (cnigs_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

LOAD DATA LOCAL INFILE 'cnigs.csv'
INTO TABLE cnigs
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

drop table if exists ihsi;
CREATE table ihsi (
  ihsi_id int(11) NOT NULL AUTO_INCREMENT,
  departement varchar(255),
  arrondissement varchar(255),
  commune varchar(255),
  section varchar(255),
  localitie varchar(255),
  type varchar (255),
  source varchar(255),
  PRIMARY KEY (ihsi_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

LOAD DATA LOCAL INFILE 'ihsi.csv'
INTO TABLE ihsi
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

UPDATE ihsi i, cnigs c SET i.arrondissement = c.arrondissement WHERE i.commune = c.commune;

drop table if exists chw;
CREATE table chw (
  chw_id int(11) NOT NULL AUTO_INCREMENT,
  departement varchar(255),
  arrondissement varchar(255),
  commune varchar(255),
  section varchar(255),
  grand_localitie varchar(255),
  ti_localitie varchar(255),
  source varchar(255),
  lat_x double NOT NULL,
  long_y double NOT NULL,
  PRIMARY KEY (chw_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

LOAD DATA LOCAL INFILE 'chw.csv'
INTO TABLE chw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

UPDATE chw w, cnigs c SET w.arrondissement = c.arrondissement WHERE w.commune = c.commune;

drop table if exists master_address_list;
CREATE table master_address_list (
  master_address_id int(11) NOT NULL AUTO_INCREMENT,
  departement varchar(255),
  arrondissement varchar(255),
  commune varchar(255),
  section varchar(255),
  localitie varchar(255),
  ti_localitie varchar(255),
  cnigs_id int(11),
  ihsi_id int(11),
  chw_id int(11),
  cnigs_fid_1 int(11),
  ihsi_type varchar(255),
  lat_x double,
  long_y double,
  PRIMARY KEY (master_address_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

INSERT INTO master_address_list SELECT NULL, departement, arrondissement, commune, section, localitie, NULL, cnigs_id, NULL, NULL, fid_1, NULL, lat_x, long_y FROM cnigs;

INSERT INTO master_address_list SELECT NULL, departement, arrondissement, commune, section, localitie, NULL, NULL, ihsi_id, NULL, NULL, NULL, NULL, NULL FROM ihsi;

INSERT INTO master_address_list SELECT NULL, departement, arrondissement, commune, section, grand_localitie, ti_localitie, NULL, NULL, chw_id, NULL, NULL, lat_x, long_y FROM chw;

SELECT * FROM (SELECT departement, commune, section, localitie, count(master_address_id) num FROM master_address_list GROUP BY departement, commune, section, localitie ORDER BY departement, commune, section, localitie) list WHERE num > 1;

SELECT * FROM (SELECT * FROM master_address_list ORDER BY cnigs_id DESC, chw_id DESC, ihsi_id DESC) list WHERE localitie = 'Corail' AND section = '3ème Thiotte' GROUP BY departement, arrondissement, commune, section, localitie;


drop table if exists master_address_list_de_duplicated;
CREATE table master_address_list_de_duplicated (
  master_address_id int(11),
  country varchar(255),
  departement varchar(255),
  arrondissement varchar(255),
  commune varchar(255),
  section varchar(255),
  localitie varchar(255),
  ti_localitie varchar(255),
  cnigs_id int(11),
  ihsi_id int(11),
  chw_id int(11),
  cnigs_fid_1 int(11),
  ihsi_type varchar(255),
  lat_x double,
  long_y double
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

INSERT INTO master_address_list_de_duplicated SELECT master_address_id, "Haiti", departement, arrondissement, commune, section, localitie, ti_localitie, cnigs_id, ihsi_id, chw_id, cnigs_fid_1, ihsi_type, lat_x, long_y FROM (SELECT * FROM master_address_list ORDER BY cnigs_id DESC, chw_id DESC, ihsi_id DESC) list GROUP BY departement, arrondissement, commune, section, localitie, ti_localitie;

SELECT country, departement, arrondissement, commune, section, localitie
INTO LOCAL OUTFILE 'haiti_address_hierarchy_1.csv' FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n'
FROM master_address_list_de_duplicated
GROUP BY country, departement, arrondissement, commune, section, localitie;

SELECT country, departement, commune, section, localitie
INTO LOCAL OUTFILE 'haiti_address_hierarchy_2.csv' FIELDS TERMINATED BY '|' LINES TERMINATED BY '\n'
FROM master_address_list_de_duplicated
GROUP BY country, departement, commune, section, localitie;
