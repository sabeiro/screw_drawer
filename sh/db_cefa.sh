create table account (
    a varchar(20),
    b varchar(20),
    c varchar(20),
    d varchar(20),
    e varchar(20),
    f varchar(20),
    g varchar(20),
    h varchar(20),
    i varchar(20),
    l varchar(20),
    m varchar(20)
);
LOAD DATA LOCAL INFILE '/home/sabeiro/Prova/CefaAccount.txt' INTO TABLE account FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' (a, b, c, d, e, f , g, h, i, l, m);
