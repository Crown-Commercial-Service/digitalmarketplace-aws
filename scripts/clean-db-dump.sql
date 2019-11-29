\set ON_ERROR_STOP on

\echo 'Update users'
UPDATE users
SET name = 'Test ' || role,
    email_address = id || '@' || role || '.marketplace.team',
    password = :bcrypt_password,
    failed_login_count = 0,
    phone_number = '01234567890';

-- Remove data about currently ongoing framework applications
\echo 'Delete draft services for open frameworks'
DELETE
FROM draft_services
WHERE framework_id IN
    (SELECT id
     FROM frameworks
     WHERE status='open');

\echo 'Delete supplier frameworks for open frameworks'
DELETE
FROM supplier_frameworks
WHERE framework_id IN
    (SELECT id
     FROM frameworks
     WHERE status='open');

-- Remove data related to open DOS procurements
-- (Delete all brief responses except those with 'awarded' status, where the procurement has ended)
\echo 'Delete brief responses'
DELETE
FROM brief_responses
WHERE awarded_at IS NULL;

-- Sanitise personal data in awarded brief responses
\echo 'Update brief responses'
UPDATE brief_responses
SET data = data::jsonb || '{"respondToEmailAddress": "cleaned-example-email@example.gov.uk"}'::jsonb
WHERE data::TEXT != '{}';

\echo 'Delete draft briefs'
\echo '  > Delete draft brief users'
DELETE
FROM brief_users
WHERE brief_id IN
    (SELECT id
     FROM briefs
     WHERE published_at IS NULL);

\echo '  > Delete draft briefs'
DELETE
FROM briefs
WHERE published_at IS NULL;

-- Remove suppliers without framework agreements or submitted services
\echo 'Delete dangling suppliers'
WITH dangling_suppliers AS -- Suppliers that are not connected to any frameworks
  (SELECT supplier_id
   FROM suppliers
   WHERE
       (SELECT COUNT(*)
        FROM supplier_frameworks
        WHERE supplier_id=suppliers.supplier_id ) = 0
     AND supplier_id NOT IN
       (SELECT DISTINCT supplier_id
        FROM services) ), d1 AS
  (DELETE
   FROM contact_information
   WHERE supplier_id IN
       (SELECT supplier_id
        FROM dangling_suppliers) ),
                          d2 AS
  (DELETE
   FROM users
   WHERE supplier_id IN
       (SELECT supplier_id
        FROM dangling_suppliers) )
DELETE
FROM suppliers
WHERE supplier_id IN
    (SELECT supplier_id
     FROM dangling_suppliers);

-- Overwrite supplier contact details
UPDATE
  contact_information
SET
  (
    contact_name,
    phone_number,
    email,
    address1,
    city,
    postcode
  ) = (
    'Supplier #' || supplier_id::TEXT || ' Contact',
    '555' || supplier_id::TEXT,
    'simulate-delivered@notifications.service.gov.uk',
    'Supplier #' || supplier_id :: TEXT || ' Contact Address 1',
    'Supplier #' || supplier_id :: TEXT || ' Contact City',
    'AA11 1AA'
);

-- Remove audit events because we don't use them
\echo 'Delete audit events'
DELETE
FROM audit_events;

-- Sanitise framework agreements because they contain personal data
\echo 'Update framework agreements'
UPDATE framework_agreements
SET
    signed_agreement_details = json_build_object(
        'signerName', 'A. Nonymous',
        'signerRole', 'The Boss',
        'uploaderUserId', signed_agreement_details->'uploaderUserId',
        'frameworkAgreementVersion', signed_agreement_details->'frameworkAgreementVersion'
    ),
    signed_agreement_path = 'not/the/real/path.pdf'
WHERE
        signed_agreement_details IS NOT NULL
    AND
        json_typeof(signed_agreement_details) != 'null';

UPDATE framework_agreements
SET countersigned_agreement_path = 'not/the/real/path.pdf'
WHERE countersigned_agreement_path IS NOT NULL;

-- Overwrite declarations with a small but hopefully valid entry
-- Removes all personal data while keeping our app working as expected
\echo 'Blank out declarations'
UPDATE supplier_frameworks
SET
    declaration = CASE WHEN (declaration->'status') IS NULL  -- i.e. key does not exist
        THEN
            '{}'::json
        ELSE
            json_strip_nulls(json_build_object(
                'status', (declaration->'status'),
                'primaryContactEmail', CASE WHEN declaration->'primaryContactEmail' IS NOT NULL THEN
                    format('%s-supplier-user@example.com', substring(id_hash from 0 for 8))
                END,
                'primaryContact', CASE WHEN declaration->'primaryContact' IS NOT NULL THEN
                    format('Jo %s. %s. Supplier', substring(id_hash_ualpha from 8 for 1), substring(id_hash_ualpha from 9 for 1))
                END,
                'contactEmailContractNotice', CASE WHEN declaration->'contactEmailContractNotice' IS NOT NULL THEN
                    format('%s-supplier-contract@example.com', substring(id_hash from 0 for 8))
                END,
                'contactNameContractNotice', CASE WHEN declaration->'contactNameContractNotice' IS NOT NULL THEN
                    format('Jo %s. %s. Supplier Esq.', substring(id_hash_ualpha from 8 for 1), substring(id_hash_ualpha from 9 for 1))
                END,
                'nameOfOrganisation', CASE WHEN declaration->'nameOfOrganisation' IS NOT NULL THEN
                    format('%s Ltd.', substring(id_hash_ualpha from 10 for 8))
                END,
                'companyRegistrationNumber', CASE WHEN declaration->'companyRegistrationNumber' IS NOT NULL THEN
                    substring(id_hash from 18 for (substring(id_hash_digits from 19 for 1)::integer + 2))
                END,
                'dunsNumber', CASE WHEN declaration->'dunsNumber' IS NOT NULL THEN
                    substring(id_hash_digits from 23 for 9)
                END,
                'registeredVATNumber', CASE WHEN declaration->'registeredVATNumber' IS NOT NULL THEN
                    substring(id_hash_digits from 14 for 9)
                END,
                'tradingNames', CASE WHEN declaration->'tradingNames' IS NOT NULL THEN
                    format('%s & Co.', substring(id_hash_ualpha from 10 for 8))
                END,
                'currentRegisteredCountry', CASE WHEN declaration->'currentRegisteredCountry' IS NOT NULL THEN
                    initcap(format('%sland', substring(id_hash_ualpha from 26 for 6)))
                END,
                -- from g-cloud 9 & before
                'registeredAddressBuilding', CASE WHEN declaration->'registeredAddressBuilding' IS NOT NULL THEN
                    initcap(format('%s house', substring(id_hash_ualpha from 14 for 6)))
                END,
                'registeredAddressTown', CASE WHEN declaration->'registeredAddressTown' IS NOT NULL THEN
                    initcap(format('%sville', substring(id_hash_ualpha from 11 for 5)))
                END,
                'registeredAddressPostcode', CASE WHEN declaration->'registeredAddressPostcode' IS NOT NULL THEN
                    upper(translate(substring(id_hash from 11 for 7), '01', '  '))
                END,
                -- from g-cloud 7
                'SQ1-1a', CASE WHEN declaration->'SQ1-1a' IS NOT NULL THEN
                    format('%s Ltd.', substring(id_hash_ualpha from 10 for 8))
                END,
                'SQ1-1e', CASE WHEN declaration->'SQ1-1e' IS NOT NULL THEN
                    substring(id_hash from 18 for (substring(id_hash_digits from 19 for 1)::integer + 2))
                END,
                'SQ1-1d-ii', CASE WHEN declaration->'SQ1-1d-ii' IS NOT NULL THEN
                    initcap(format('%sland', substring(id_hash_ualpha from 26 for 6)))
                END,
                -- injected into declaration from supplier contact details at award time
                'supplierDunsNumber', CASE WHEN declaration->'supplierDunsNumber' IS NOT NULL THEN
                    substring(id_hash_digits from 23 for 9)
                END,
                'supplierRegisteredBuilding', CASE WHEN declaration->'supplierRegisteredBuilding' IS NOT NULL THEN
                    initcap(format('%s house', substring(id_hash_ualpha from 14 for 6)))
                END,
                'supplierRegisteredCountry', CASE WHEN declaration->'supplierRegisteredCountry' IS NOT NULL THEN
                    format('country:%s', substring(id_hash_ualpha from 4 for 2))
                END,
                'supplierRegisteredName', CASE WHEN declaration->'supplierRegisteredName' IS NOT NULL THEN
                    format('%s Ltd.', substring(id_hash_ualpha from 10 for 8))
                END,
                'supplierRegisteredPostcode', CASE WHEN declaration->'supplierRegisteredPostcode' IS NOT NULL THEN
                    upper(translate(substring(id_hash from 11 for 7), '01', '  '))
                END,
                'supplierRegisteredTown', CASE WHEN declaration->'supplierRegisteredTown' IS NOT NULL THEN
                    initcap(format('%sville', substring(id_hash_ualpha from 11 for 5)))
                END,
                'supplierTradingName', CASE WHEN declaration->'supplierTradingName' IS NOT NULL THEN
                    format('%s & Co.', substring(id_hash_ualpha from 10 for 8))
                END,
                'supplierVatNumber', CASE WHEN declaration->'supplierVatNumber' IS NOT NULL THEN
                    substring(id_hash_digits from 14 for 9)
                END
            ))
    END
FROM (
    -- join against a subquery based on same table to allow us to calculate md5 only once
    SELECT
        supplier_id,
        framework_id,
        md5(supplier_id::text || '|' || framework_id::text) AS id_hash,
        upper(translate(md5(supplier_id::text || '|' || framework_id::text), '0123456789', 'IOUYGHJKLM')) AS id_hash_ualpha,
        translate(md5(supplier_id::text || '|' || framework_id::text), 'abcdef', '987654') AS id_hash_digits
    FROM supplier_frameworks
) AS annotation
WHERE supplier_frameworks.supplier_id = annotation.supplier_id AND supplier_frameworks.framework_id = annotation.framework_id
  AND declaration IS NOT NULL
  AND json_typeof(declaration) != 'null'
  AND declaration::text != '{}';

-- Create some fake draft and submitted brief responses on closed briefs using eligible suppliers
-- Ensuring essential requirements evidence length matches that of the brief essential requirements
-- and nice to have requirements are representative of possible data given brief nice to have requirements
\echo 'Generate fake brief_responses'
INSERT INTO brief_responses (
      data,
      brief_id,
      supplier_id,
      created_at,
      submitted_at
)
SELECT
    -- create 'data' column with varying numbers of evidence
    json_strip_nulls(json_build_object(
        'essentialRequirements', array_fill('{"evidence": "Some essential evidence."}'::json, ARRAY[essential_requirements_len]),
        'niceToHaveRequirements', CASE
            WHEN  -- If there are no nice to have requirements or if it's in in 1/15 of all drafts then don't add the key at all
                    nice_to_have_requirements_len::BOOL = FALSE
                OR (
                    MOD(eligible_brief_supplier_pairings.supplier_id, 3) = 0 AND MOD(eligible_brief_supplier_pairings.supplier_id, 5) = 0
                )
            THEN
                null  -- entry should be stripped out by json_strip_nulls
            ELSE  -- Otherwise all true
                array_fill('{"yesNo": true, "evidence": "Some nice to have evidence."}'::json, ARRAY[nice_to_have_requirements_len])
        END,
        'availability', '09/09/17',
        'essentialRequirementsMet', true,
        'respondToEmailAddress', 'example-email@example.gov.uk'
    )),
    eligible_brief_supplier_pairings.brief_id,
    eligible_brief_supplier_pairings.supplier_id,
    now(),
    CASE WHEN MOD(eligible_brief_supplier_pairings.supplier_id, 5) = 0
      THEN NULL
      ELSE now()
    END
FROM (
    SELECT DISTINCT ON (briefs.id)
      briefs.id AS brief_id,
      supplier_id as supplier_id,
      json_array_length((data->>'essentialRequirements')::json) as essential_requirements_len,
      json_array_length((data->>'niceToHaveRequirements')::json) as nice_to_have_requirements_len
    FROM supplier_frameworks
      LEFT JOIN frameworks ON supplier_frameworks.framework_id = frameworks.id
      LEFT JOIN briefs ON briefs.framework_id = frameworks.id
    WHERE declaration->>'status' = 'complete'
      AND frameworks.slug LIKE 'digital-outcomes-and-specialists-_'
      AND briefs.published_at <= now() - '2 weeks 1 day'::interval
) AS eligible_brief_supplier_pairings;

-- PaaS have an event trigger which invokes a function to reassign the owner of an object
-- The function checks if the current user has a particular role. If that role doesn't exist
-- in the database it causes an error. Removing the trigger prevents the function being executed.
\echo 'Remove PaaS event trigger'
DROP EVENT TRIGGER reassign_owned;
