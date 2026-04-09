-- Generate simulated fiber network nodes along major roads
-- Nodes placed every ~20% of each road segment length
-- Road types: primary, secondary, tertiary, trunk (realistic fiber routes)

CREATE TABLE generated_fiber_nodes AS
SELECT 
    ROW_NUMBER() OVER () AS id,
    ST_LineInterpolatePoint(
        ST_LineMerge(geom),
        gs.frac
    ) AS geom
FROM roads,
     generate_series(0.0, 1.0, 0.20) AS gs(frac)
WHERE fclass IN (
    'primary', 'primary_link',
    'secondary', 'secondary_link',
    'tertiary', 'tertiary_link',
    'trunk', 'trunk_link'
);

CREATE INDEX idx_gen_fiber_geom
    ON generated_fiber_nodes USING GIST(geom);

-- Result: 478,218 fiber nodes generated across Saxony