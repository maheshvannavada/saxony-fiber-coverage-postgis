-- Coverage summary: buildings within 500m of a fiber node
SELECT
    (SELECT COUNT(*) FROM buildings) AS total_buildings,
    COUNT(*) AS covered,
    (SELECT COUNT(*) FROM buildings) - COUNT(*) AS uncovered,
    ROUND(100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM buildings), 2) AS coverage_pct
FROM buildings b
WHERE EXISTS (
    SELECT 1 FROM generated_fiber_nodes f
    WHERE ST_DWithin(b.geom, f.geom, 500)
);
-- Result: 90.12% coverage (1,617,348 of 1,794,566 buildings)

-- Create covered buildings table
CREATE TABLE final_covered_buildings AS
SELECT b.id, b.geom
FROM buildings b
WHERE EXISTS (
    SELECT 1 FROM generated_fiber_nodes f
    WHERE ST_DWithin(b.geom, f.geom, 500)
);
CREATE INDEX idx_final_covered_geom
    ON final_covered_buildings USING GIST(geom);

-- Create uncovered buildings table (coverage gap)
CREATE TABLE final_uncovered_buildings AS
SELECT b.id, b.geom
FROM buildings b
WHERE NOT EXISTS (
    SELECT 1 FROM generated_fiber_nodes f
    WHERE ST_DWithin(b.geom, f.geom, 500)
);
CREATE INDEX idx_final_uncovered_geom
    ON final_uncovered_buildings USING GIST(geom);