

SELECT LISTAGG(orgname, ',,,') WITHIN GROUP (ORDER BY busno desc) as busnos
FROM s_busi WHERE busno IN(81001,81002);  --https://blog.csdn.net/weixin_45422361/article/details/118768731
