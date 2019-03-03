/*---- Creating a Redshift schema for BU Assessment data Analytics ---*/


-- Create Schema bec_edw
CREATE SCHEMA bec_edw authorization master;

-- Create User in redshift , please change password accordingly(Should contains 1 numeric,1 Upper case, minimum 8 characters)
CREATE USER api_login password 'NewPassword1';
CREATE USER temp_tester password 'NewPassword1';

-- Grant access to the users on schema
GRANT ALL ON schema bec_edw TO api_login;
GRANT ALL ON schema bec_edw TO temp_tester;

-- Create table bec_edw.bu_assessment_reporting_detail

DROP TABLE IF EXISTS bec_edw.bu_assessment_reporting_detail CASCADE;
CREATE TABLE IF NOT EXISTS bec_edw.bu_assessment_reporting_detail
(
  test_id INTEGER   ENCODE RAW
  ,bu_district_id INTEGER   ENCODE RAW
  ,bu_school_id INTEGER   ENCODE RAW
  ,bu_assignment_id INTEGER   ENCODE RAW
  ,student_id INTEGER   ENCODE RAW
  ,start_time VARCHAR(20)   ENCODE zstd
  ,end_time VARCHAR(20)  ENCODE zstd
  ,collective_noun_id INTEGER   ENCODE RAW
  ,status VARCHAR(20)   ENCODE zstd
  ,test_score DOUBLE PRECISION   ENCODE zstd
  ,grade INTEGER   ENCODE RAW
  ,created_at VARCHAR(20)  ENCODE zstd
  ,updated_at VARCHAR(20)   ENCODE zstd
  ,deleted VARCHAR(5)   ENCODE zstd
  ,component_code VARCHAR(20)   ENCODE zstd
  ,component_title VARCHAR(200)   ENCODE zstd
  ,created_by_id INTEGER   ENCODE RAW
  ,elapsed_time INTEGER   ENCODE RAW
  ,version VARCHAR(8)   ENCODE zstd
  ,keyword VARCHAR(100)   ENCODE zstd
  ,identifier VARCHAR(50)   ENCODE zstd
  ,feedback VARCHAR(1000)   ENCODE zstd
  ,max_score DOUBLE PRECISION   ENCODE zstd
  ,interaction_id INTEGER   ENCODE RAW
  ,instances_interaction_id INTEGER   ENCODE RAW
  ,graded_by INTEGER   ENCODE RAW
  ,correct_response VARCHAR(4000)   ENCODE zstd
  ,response_identifier VARCHAR(20)   ENCODE zstd
  ,response VARCHAR(8000)   ENCODE zstd
  ,score DOUBLE PRECISION   ENCODE zstd
  ,standards VARCHAR(4000)   ENCODE zstd
  ,strands VARCHAR(255)   ENCODE zstd
  ,skillname VARCHAR(255)   ENCODE zstd
  ,claimsandtargets VARCHAR(255)   ENCODE zstd
  ,dok VARCHAR(255)   ENCODE zstd
  ,min_score DOUBLE PRECISION   ENCODE zstd
  ,comments VARCHAR(1000)   ENCODE zstd
  ,rec_created_date TIMESTAMP WITHOUT TIME ZONE  ENCODE zstd DEFAULT GETDATE()
)
DISTSTYLE EVEN
 SORTKEY (
  bu_school_id
  , collective_noun_id
  )
;
GRANT SELECT ON bec_edw.bu_assessment_reporting_detail TO api_login;
GRANT SELECT,INSERT ON bec_edw.bu_assessment_reporting_detail TO temp_tester;

--Create View bu_assessment_reporting_detail_vw  


DROP VIEW IF EXISTS bec_edw.bu_assessment_reporting_detail_vw CASCADE;
CREATE VIEW bec_edw.bu_assessment_reporting_detail_vw
AS 
 SELECT bu_assessment_reporting_detail.test_id,
       bu_assessment_reporting_detail.bu_district_id,
       bu_assessment_reporting_detail.bu_school_id,
       bu_assessment_reporting_detail.bu_assignment_id,
       bu_assessment_reporting_detail.student_id,
       bu_assessment_reporting_detail.start_time::TIMESTAMP without TIME zone AS start_time,
       bu_assessment_reporting_detail.end_time::TIMESTAMP without TIME zone AS end_time,
       bu_assessment_reporting_detail.collective_noun_id,
       bu_assessment_reporting_detail.status,
       bu_assessment_reporting_detail.test_score,
       bu_assessment_reporting_detail.grade,
       bu_assessment_reporting_detail.created_at::TIMESTAMP without TIME zone AS created_at,
       bu_assessment_reporting_detail.updated_at::TIMESTAMP without TIME zone AS updated_at,
       CASE
         WHEN LTRIM(RTRIM(bu_assessment_reporting_detail.deleted::TEXT)) = 'f'::TEXT THEN 'false'::TEXT
         ELSE 'true'::TEXT
       END AS deleted,
       bu_assessment_reporting_detail.component_code,
       bu_assessment_reporting_detail.component_title,
       bu_assessment_reporting_detail.created_by_id,
       bu_assessment_reporting_detail.elapsed_time,
       bu_assessment_reporting_detail.version,
       bu_assessment_reporting_detail.keyword,
       bu_assessment_reporting_detail.identifier,
       bu_assessment_reporting_detail.feedback,
       bu_assessment_reporting_detail.max_score,
       bu_assessment_reporting_detail.interaction_id,
       bu_assessment_reporting_detail.instances_interaction_id,
       bu_assessment_reporting_detail.graded_by,
       bu_assessment_reporting_detail.correct_response,
       bu_assessment_reporting_detail.response_identifier,
       bu_assessment_reporting_detail.response,
       bu_assessment_reporting_detail.score,
       bu_assessment_reporting_detail.standards,
       bu_assessment_reporting_detail.strands,
       bu_assessment_reporting_detail.skillname,
       bu_assessment_reporting_detail.claimsandtargets,
       bu_assessment_reporting_detail.dok,
       bu_assessment_reporting_detail.min_score,
       bu_assessment_reporting_detail.comments,
       bu_assessment_reporting_detail.rec_created_date
FROM bec_edw.bu_assessment_reporting_detail
WHERE identifier::text <> ''::character varying::text;

GRANT SELECT ON bec_edw.bu_assessment_reporting_detail_vw TO api_login;
GRANT SELECT ON bec_edw.bu_assessment_reporting_detail_vw TO temp_tester;


-- Create View bu_strand_details_vw
DROP VIEW IF EXISTS bec_edw.bu_strand_details_vw CASCADE;
CREATE VIEW bec_edw.bu_strand_details_vw
(
  student_id,
  collective_noun_id,
  component_code,
  component_title,
  bu_school_id,
  updatedat,
  score,
  max_score,
  identifier,
  question_no,
  standard_id
)
AS 
WITH standards_cal AS (
SELECT * FROM ( 
SELECT 
 bu_district_id, 
 bu_school_id, 
 student_id, 
 start_time::timestamp without time zone AS start_time, 
 end_time::timestamp without time zone AS end_time, 
 collective_noun_id, 
 status,
test_score,  
 created_at::timestamp without time zone AS created_at, 
 updated_at::timestamp without time zone AS updated_at, 
 component_code, 
 component_title, 
 keyword, 
 identifier, 
 avg(max_score) max_score, 
 sum(score) score, 
 standards
FROM bec_edw.bu_assessment_reporting_detail   where LTRIM(RTRIM(status)) = 'GRADED' and LTRIM(RTRIM(identifier))<>''
GROUP BY bu_district_id, 
 bu_school_id, 
 student_id, 
 start_time, 
 end_time, 
 collective_noun_id, 
 status,
test_score,  
 created_at, 
 updated_at, 
 component_code, 
 component_title, 
 keyword, 
 identifier,  
 standards
)x 
),
standards_div AS (
SELECT DISTINCT
student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
test_score,
score,
max_score,
identifier,
LTRIM(RTRIM(SPLIT_PART(standards,',',1))) as standard_id
FROM standards_cal
UNION ALL
SELECT DISTINCT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
test_score,
score,
max_score,
identifier,
LTRIM(RTRIM(SPLIT_PART(standards,',',2))) standards
FROM standards_cal
UNION ALL
SELECT DISTINCT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
test_score,
score,
max_score,
identifier,
LTRIM(RTRIM(SPLIT_PART(standards,',',3))) standards
FROM standards_cal
UNION ALL
SELECT DISTINCT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
test_score,
score,
max_score,
identifier,
LTRIM(RTRIM(SPLIT_PART(standards,',',4))) standards
FROM standards_cal
UNION ALL
SELECT DISTINCT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
test_score,
score,
max_score,
identifier,
LTRIM(RTRIM(SPLIT_PART(standards,',',5))) standards
FROM standards_cal
),
standards_dtrnk AS (
SELECT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
score,
max_score,
identifier,question_no,
standard_id FROM (
Select 
student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
score,
max_score,
identifier,
cast(right(ltrim(rtrim(identifier)),3) as integer) AS question_no,
standard_id,dense_rank() over(partition by 
collective_noun_id,student_id,component_code order by updated_at desc) rnk
from standards_div strnd
where standard_id<>'' 
 )x where rnk =1
 )
SELECT student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at as updatedAt,
score,
max_score,
identifier,
question_no,
standard_id FROM (
SELECT  student_id,
collective_noun_id,
component_code,
component_title,
bu_school_id,
updated_at,
score,
max_score,
identifier,question_no,
standard_id,
row_number() over(partition by 
collective_noun_id,student_id,component_code,standard_id,identifier,max_score,score 
order by standard_id,identifier,max_score,score desc) row_number
FROM standards_dtrnk)x WHERE row_number=1;



GRANT SELECT ON bec_edw.bu_strand_details_vw TO api_login;
GRANT SELECT ON bec_edw.bu_strand_details_vw TO temp_tester; 





--Create View bu_testscore_dtl_vw  

DROP VIEW IF EXISTS bec_edw.bu_testscore_dtl_vw CASCADE;
CREATE VIEW bec_edw.bu_testscore_dtl_vw
(
  bu_school_id,
  collective_noun_id,
  student_id,
  component_code,
  component_title,
  updated_at,
  test_score,
  max_score,
  std_prcnt
)
AS 
SELECT qstdtl.bu_school_id,qstdtl.collective_noun_id,qstdtl.student_id,qstdtl.component_code,qstdtl.component_title,qstdtl.updated_at, qstdtl.test_score,ms.max_score,round((qstdtl.test_score/ms.max_score)*100) as std_prcnt
FROM
(
SELECT bu_school_id,collective_noun_id,student_id,component_code,component_title,updated_at updated_at,test_score
FROM 
(
SELECT bu_school_id,collective_noun_id,student_id,component_code,component_title,updated_at updated_at,max(test_score) test_score,dense_rank() over(partition by 
collective_noun_id,student_id,component_code order by updated_at desc) rnk
FROM bec_edw.bu_assessment_reporting_detail_vw where LTRIM(RTRIM(status)) = 'GRADED'  
GROUP BY bu_school_id,collective_noun_id,student_id,component_code,component_title,updated_at
)x WHERE rnk=1
)qstdtl
JOIN
(SELECT student_id,component_code,sum(max_score) max_score from 
(SELECT student_id,component_code,identifier,max_score,test_score, response_identifier,dense_rank() over(partition by 
student_id,component_code,identifier order by response_identifier desc) rnk1 
from bec_edw.bu_assessment_reporting_detail_vw where LTRIM(RTRIM(status)) = 'GRADED' 
GROUP BY student_id,component_code,identifier,max_score,test_score,response_identifier
)x where rnk1= 1
GROUP BY student_id,component_code
) ms
ON qstdtl.component_code=ms.component_code
AND qstdtl.student_id=ms.student_id;

GRANT SELECT ON bec_edw.bu_testscore_dtl_vw TO api_login;
GRANT SELECT ON bec_edw.bu_testscore_dtl_vw TO temp_tester; 


--Create View bu_question_detail_vw

DROP VIEW IF EXISTS bec_edw.bu_question_detail_vw CASCADE;
CREATE OR REPLACE VIEW bec_edw.bu_question_detail_vw
(
  question_identifier,
  max_score,
  correct_response,
  standards,
  strand,
  skill_name,
  claims_and_targets,
  dok,
  min_score
)
AS 
 SELECT ltrim(rtrim(bu_assessment_reporting_detail.identifier::text)) AS question_identifier, bu_assessment_reporting_detail.max_score, bu_assessment_reporting_detail.correct_response, ltrim(rtrim(bu_assessment_reporting_detail.standards::text)) AS standards, ltrim(rtrim(bu_assessment_reporting_detail.strands::text)) AS strand, ltrim(rtrim(bu_assessment_reporting_detail.skillname::text)) AS skill_name, ltrim(rtrim(bu_assessment_reporting_detail.claimsandtargets::text)) AS claims_and_targets, ltrim(rtrim(bu_assessment_reporting_detail.dok::text)) AS dok, bu_assessment_reporting_detail.min_score
   FROM bec_edw.bu_assessment_reporting_detail;


GRANT SELECT ON bec_edw.bu_question_detail_vw TO temp_tester;
GRANT SELECT ON bec_edw.bu_question_detail_vw TO api_login;

--Create View bu_student_test_detail_vw


DROP VIEW IF EXISTS bec_edw.bu_student_test_detail_vw CASCADE;
CREATE OR REPLACE VIEW bec_edw.bu_student_test_detail_vw
(
  test_id,
  bu_assignment_id,
  start_time,
  end_time,
  collective_noun_id,
  test_score,
  grade,
  created_at,
  updated_at,
  student_id,
  identifier,
  interaction_id,
  response_recorded,
  response_identifier,
  score,
  feedback,
  elapsed_time,
  status,
  comments
)
AS 
 SELECT bu_assessment_reporting_detail.test_id, bu_assessment_reporting_detail.bu_assignment_id, bu_assessment_reporting_detail.start_time, bu_assessment_reporting_detail.end_time, bu_assessment_reporting_detail.collective_noun_id, bu_assessment_reporting_detail.test_score, bu_assessment_reporting_detail.grade, bu_assessment_reporting_detail.created_at, bu_assessment_reporting_detail.updated_at, bu_assessment_reporting_detail.student_id, bu_assessment_reporting_detail.identifier, bu_assessment_reporting_detail.interaction_id, bu_assessment_reporting_detail.response AS response_recorded, bu_assessment_reporting_detail.response_identifier, bu_assessment_reporting_detail.score, bu_assessment_reporting_detail.feedback, bu_assessment_reporting_detail.elapsed_time, bu_assessment_reporting_detail.status, bu_assessment_reporting_detail.comments
   FROM bec_edw.bu_assessment_reporting_detail
  WHERE bu_assessment_reporting_detail.identifier::text <> ''::character varying::text;

GRANT SELECT ON bec_edw.bu_student_test_detail_vw TO temp_tester;
GRANT SELECT ON bec_edw.bu_student_test_detail_vw TO api_login;

--Create View bu_assignment_detail_vw

DROP VIEW IF EXISTS bec_edw.bu_assignment_detail_vw CASCADE;
CREATE OR REPLACE VIEW bec_edw.bu_assignment_detail_vw
(
  test_id,
  bu_district_id,
  bu_school_id,
  bu_assignment_id,
  status,
  component_code,
  component_title,
  assignment_created_dt,
  assignment_updated_dt,
  assignment_keywords,
  version,
  deleted,
  created_by_id
)
AS 
 SELECT DISTINCT bu_assessment_reporting_detail.test_id, bu_assessment_reporting_detail.bu_district_id, bu_assessment_reporting_detail.bu_school_id, bu_assessment_reporting_detail.bu_assignment_id, bu_assessment_reporting_detail.status, bu_assessment_reporting_detail.component_code, bu_assessment_reporting_detail.component_title, ltrim(rtrim(bu_assessment_reporting_detail.created_at::text))::timestamp without time zone AS assignment_created_dt, ltrim(rtrim(bu_assessment_reporting_detail.updated_at::text))::timestamp without time zone AS assignment_updated_dt, bu_assessment_reporting_detail.keyword AS assignment_keywords, bu_assessment_reporting_detail.version, bu_assessment_reporting_detail.deleted, bu_assessment_reporting_detail.created_by_id
   FROM bec_edw.bu_assessment_reporting_detail;


GRANT SELECT ON bec_edw.bu_assignment_detail_vw TO temp_tester;
GRANT SELECT ON bec_edw.bu_assignment_detail_vw TO api_login;




 

