
SELECT COUNT(*) FROM buildings b
WHERE NOT EXISTS (
    SELECT 1 FROM generated_fiber_nodes f
    WHERE ST_DWithin(b.geom, f.geom, 500)
);
