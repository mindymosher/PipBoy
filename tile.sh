#!/bin/sh

psql -d roads -c "copy(select encode(
         st_aspng(
           st_asraster(
             (
                select ST_Union(st_intersection(st_transform(geom, 3857), st_transform(bbox, 3857))) from roads,
                 (select st_expand(st_setsrid(st_point($1, $2), 4326)::geometry, $3) bbox) b
                where geom && bbox
             ),
             170, 170, ARRAY['8BUI','8BUI', '8BUI'], ARRAY[127,255,0], ARRAY[0,0,0]
           )
         ), 'hex')) TO '/root/file.hex';"

xxd -p -r /root/file.hex > map.png

