-- Author: Supun Jayathilake (supunj@gmail.com)

DROP TABLE IF EXISTS all_ways;

-- Ways to split ---------------------------------------------------------------------------------------------------------

CREATE TABLE all_ways AS
SELECT DISTINCT way_id, sort(array_agg(sequence_id)) split_nodes
FROM way_nodes INNER JOIN ways ON way_nodes.way_id = ways.id
WHERE ways.tags ? 'highway' AND
      array_length(ways.nodes, 1) > 2 AND
      way_nodes.node_id IN (
				SELECT node_id
				FROM way_nodes
				GROUP BY node_id
				HAVING count(node_id) > 1
			   )
GROUP BY way_id
ORDER BY way_id;

--------------------------------------------------------------------------------------------------------------------------

SELECT * FROM all_ways;

-- function to split ways ------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION generate_way_nodes(way_id bigint, nodes bigint[])
RETURNS boolean AS $$
BEGIN
	FOR i IN 1..array_length(nodes, 1) LOOP
		INSERT INTO way_nodes(way_id, node_id, sequence_id) values(way_id, nodes[i], i-1);
	END LOOP;
	RETURN true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION split_ways()
RETURNS integer AS $$
DECLARE
	splitable_way RECORD;
	number_of_ways integer DEFAULT 0;
	next_way_id bigint;
	seq_arr integer[];
	seq integer;
	way_to_split RECORD;
	seq1 integer;
	seq2 integer;
BEGIN
	SELECT max(id) + 1 FROM ways INTO next_way_id;

	FOR splitable_way IN SELECT way_id, split_nodes FROM all_ways ORDER BY way_id DESC LOOP

		SELECT * INTO way_to_split FROM ways WHERE id = splitable_way.way_id AND tags ? 'highway';

		--SELECT (sort(array_agg(sequence_id))) INTO seq_arr FROM way_nodes WHERE way_id = splitable_way.way_id GROUP BY way_id;
		seq_arr = splitable_way.split_nodes;
		IF splitable_way.split_nodes[1] != 0
		THEN
			seq_arr = 0 || splitable_way.split_nodes;
		END IF;

		IF splitable_way.split_nodes[array_upper(splitable_way.split_nodes, 1)] < (array_length(way_to_split.nodes, 1) - 1)
		THEN
			seq_arr = seq_arr || array_length(way_to_split.nodes, 1) - 1;
		END IF;

		RAISE NOTICE '%', seq_arr;
		FOR i IN 1..array_length(seq_arr, 1) LOOP
			seq1 = seq_arr[i] + 1;
			seq2 = seq_arr[i+1] + 1;

			IF seq1 = 1 THEN
				-- update way
				UPDATE ways SET nodes = way_to_split.nodes[seq1:seq2] WHERE id = splitable_way.way_id;

				-- delete original way node entry
				DELETE FROM way_nodes WHERE way_id = splitable_way.way_id;

				-- re-generate way nodes
				PERFORM generate_way_nodes(splitable_way.way_id, way_to_split.nodes[seq1:seq2]);

				RAISE NOTICE '%', 'update';
			ELSEIF seq2 IS NOT NULL THEN
				-- insert way
				INSERT INTO ways(id, version, user_id, tstamp, changeset_id, tags, nodes) VALUES(next_way_id, way_to_split.version, way_to_split.user_id, way_to_split.tstamp, way_to_split.changeset_id, way_to_split.tags, way_to_split.nodes[seq1:seq2]);

				-- generate way nodes
				PERFORM generate_way_nodes(next_way_id, way_to_split.nodes[seq1:seq2]);

				next_way_id = next_way_id + 1;
				RAISE NOTICE '%', 'insert';
			END IF;
		END LOOP;

		number_of_ways = number_of_ways + 1;
	END LOOP;

	RETURN seq_arr[1];
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------------------------------------------------

SELECT split_ways();
