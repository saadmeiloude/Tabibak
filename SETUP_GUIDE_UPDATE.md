# Database Schema Fix - Important Update

## MySQL Key Length Error Solution

If you encountered the MySQL error:
```
#1071 - La clé est trop longue. Longueur maximale: 1000
```

This has been fixed in the updated schema file.

## Use the Fixed Schema File

Instead of using `schema.sql`, please use `schema_fixed.sql`:

1. Go to `backend/database/` folder
2. Open `schema_fixed.sql` (NOT schema.sql)
3. Copy its contents
4. In phpMyAdmin, select the `tabibak` database
5. Go to the SQL tab and paste the schema
6. Click "Go" to execute

## What Was Fixed

The fixed schema includes:
- Reduced VARCHAR lengths to prevent key length issues
- Email: VARCHAR(150) instead of VARCHAR(255)
- Full name: VARCHAR(100) instead of VARCHAR(255)
- Title: VARCHAR(200) instead of longer lengths
- Emergency contact: VARCHAR(50) instead of VARCHAR(255)

These changes ensure all indexes stay within the 1000-byte MySQL limit while maintaining full functionality.

## All Other Setup Steps Remain the Same

The rest of the setup process in the main SETUP_GUIDE.md remains unchanged. Only the database schema import step needs to use the fixed file.

## Testing After Fix

After importing the fixed schema, you can test with:
- Admin: admin@tabibak.com / password
- Doctor: doctor@tabibak.com / password  
- Patient: patient@tabibak.com / password

The MySQL key length error should now be resolved.