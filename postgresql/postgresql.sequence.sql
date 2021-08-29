-- set the next value of a sequence:

SELECT setval('SEQUENCE_NAME', (SELECT MAX(SEQUENCE_COLUMN) FROM TABLE_NAME) + 1);

-- get the next value of a sequence:

SELECT nextval('SEQUENCE_NAME');
