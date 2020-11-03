-- select SUM(popn_white)
-- from nyc_census_blocks as census
-- join nyc_subway_stations as subways
-- on ST_DWithin(census.geom, subways.geom, 200)
-- where strpos(subways.routes, 'A') > 0;

SELECT s.color, SUM(CAST (num_victim AS INTEGER))
FROM nyc_homicides AS h
JOIN nyc_subway_stations AS s
ON ST_DWithin(h.geom, s.geom, 200)
GROUP BY s.color;

SELECT unnest(string_to_array(s.color, '-')), SUM(CAST (num_victim AS INTEGER))
FROM nyc_homicides AS h
JOIN nyc_subway_stations AS s
ON ST_DWithin(h.geom, s.geom, 200)
GROUP BY unnest(string_to_array(s.color, '-'));

SELECT n.name, SUM(c.popn_total) / (ST_Area(n.geom) / 1000000.0) AS density
FROM nyc_census_blocks AS c
JOIN nyc_neighborhoods AS n
ON ST_Intersects(c.geom, n.geom)
GROUP BY n.name, n.geom
ORDER BY density DESC LIMIT 3;

CREATE INDEX nyc_neighborhoods_geom_index ON nyc_neighborhoods(geom);

CREATE INDEX nyc_census_blocks_geom_index ON nyc_census_blocks(geom);

EXPLAIN ANALYZE
SELECT n.name, SUM(c.popn_total) / (ST_Area(n.geom) / 1000000.0) AS density
FROM nyc_census_blocks AS c
JOIN nyc_neighborhoods AS n
ON ST_Intersects(c.geom, n.geom)
GROUP BY n.name, n.geom
ORDER BY density DESC LIMIT 3;

CREATE INDEX nyc_census_blocks_geom_idx 
ON nyc_census_blocks
USING GIST (geom);

CREATE INDEX nyc_neighborhoods_geom_idx 
ON nyc_neighborhoods
USING GIST (geom);

EXPLAIN ANALYZE
SELECT n.name, SUM(c.popn_total) / (ST_Area(n.geom) / 1000000.0) AS density
FROM nyc_census_blocks AS c
JOIN nyc_neighborhoods AS n
ON ST_Intersects(c.geom, n.geom)
GROUP BY n.name, n.geom
ORDER BY density DESC LIMIT 3;
