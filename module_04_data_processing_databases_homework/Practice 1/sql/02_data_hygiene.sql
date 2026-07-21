-- Stage 3: Data hygiene and cleanup

-- Remove duplicate employees (keep one row per employee_id)
DELETE FROM silver.employees a
USING silver.employees b
WHERE a.employee_id = b.employee_id
  AND a.ctid < b.ctid;

-- Remove rows with missing primary key
DELETE FROM silver.employees
WHERE employee_id IS NULL;

-- Remove orphan employees (no sales records)
DELETE FROM silver.employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.sales s
    WHERE s.employee_id = e.employee_id
);
