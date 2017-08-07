\echo 'Update users'
UPDATE users
SET name = 'Test user',
    email_address = id || '@user.marketplace.team',
    password = :bcrypt_password;

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
-- (We can't tell if a procurement is ongoing, so delete all brief responses)
\echo 'Delete brief responses'
DELETE
FROM brief_responses;

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

-- Remove audit events because we don't use them
\echo 'Delete audit events'
DELETE
FROM audit_events;

-- Remove framework agreements because they contain personal data and we don't rely on them
\echo 'Delete framework agreements'
DELETE
FROM framework_agreements;

-- Overwrite declarations with the smallest possible valid entry
-- Removes all personal data while keeping our app working as expected
\echo 'Blank out declarations'
UPDATE supplier_frameworks
SET declaration = (
    CASE
    WHEN (declaration->'status') IS NULL OR (declaration->'nameOfOrganisation') IS NULL
    THEN '{}'
    ELSE '{
         "status": "' || (declaration->>'status') || '",
         "nameOfOrganisation": "' || replace((declaration->>'nameOfOrganisation'), '"', '') || '",
         "primaryContactEmail": "supplier-user@example.com",
         "organisationSize": "' || (ARRAY['micro', 'small', 'medium', 'large'])[MOD(supplier_id, 4)+1] || '"
         }'
    END)::json
WHERE declaration IS NOT NULL
  AND declaration::varchar != 'null'
  AND declaration::varchar != '{}';
