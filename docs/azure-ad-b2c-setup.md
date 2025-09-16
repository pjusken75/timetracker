# Azure AD B2C Setup Guide

This guide walks you through setting up Azure AD B2C for the TimeTracker application.

## Overview

Azure AD B2C provides:
- User registration and sign-in
- Password reset functionality  
- Multi-factor authentication (MFA)
- Social identity providers (Google, Facebook, etc.)
- Custom branding and user flows

## Step 1: Create Azure AD B2C Tenant

1. **Navigate to Azure Portal**
   - Go to https://portal.azure.com
   - Search for "Azure AD B2C"

2. **Create New B2C Tenant**
   - Click "Create a new Azure AD B2C Tenant"
   - Choose "Create a new Azure AD B2C tenant"
   - Fill in the details:
     - Organization name: `TimeTracker`
     - Initial domain name: `timetracker` (will become timetracker.onmicrosoft.com)
     - Country/Region: Select your region
   - Click "Create"

## Step 2: Configure User Flows

### Sign-up and Sign-in Flow

1. **Navigate to User Flows**
   - In your B2C tenant, go to "User flows"
   - Click "New user flow"

2. **Create Sign-up and Sign-in Flow**
   - Select "Sign up and sign in"
   - Choose "Recommended" version
   - Name: `B2C_1_signupsignin`

3. **Identity Providers**
   - Select "Email signup"
   - Optionally add social providers (Google, Microsoft, etc.)

4. **User Attributes**
   - Collect during sign-up:
     - ✅ Given Name
     - ✅ Surname
     - ✅ Email Address
   - Return in token:
     - ✅ Given Name  
     - ✅ Surname
     - ✅ Email Addresses
     - ✅ User's Object ID

5. **Create the Flow**

### Password Reset Flow

1. **Create New User Flow**
   - Type: "Password reset"
   - Version: "Recommended"
   - Name: `B2C_1_passwordreset`

2. **Configure Claims**
   - Return claims:
     - ✅ Email Addresses
     - ✅ Given Name
     - ✅ Surname

## Step 3: Register Applications

### Register the API Application

1. **App Registrations**
   - Go to "App registrations" 
   - Click "New registration"

2. **API App Details**
   - Name: `TimeTracker API`
   - Supported account types: "Accounts in any identity provider or organizational directory"
   - Redirect URI: Leave blank for now
   - Click "Register"

3. **Configure API App**
   - Note the **Application (client) ID**
   - Go to "Expose an API"
   - Click "Set" next to Application ID URI
   - Accept the default or use: `https://yourtenant.onmicrosoft.com/timetracker-api`
   - Add a scope:
     - Scope name: `access_as_user`
     - Display name: `Access TimeTracker API`
     - Description: `Allows the app to access the TimeTracker API on behalf of the signed-in user`

### Register the Frontend Application

1. **New App Registration**
   - Name: `TimeTracker Web`
   - Account types: "Accounts in any identity provider or organizational directory"
   - Redirect URI: 
     - Type: "Single-page application (SPA)"
     - URI: `http://localhost:3000` (for development)

2. **Configure Frontend App**
   - Note the **Application (client) ID**
   - Go to "API permissions"
   - Add permission → "My APIs" → Select your TimeTracker API
   - Select the `access_as_user` scope
   - Grant admin consent

3. **Production Configuration**
   - Add production redirect URI when deployed
   - Update CORS settings as needed

## Step 4: Update Application Configuration

### Frontend Configuration (`.env.local`)

```bash
# Azure AD B2C Configuration
VITE_AZURE_CLIENT_ID=<frontend-app-client-id>
VITE_AZURE_TENANT_ID=<your-tenant-name>
VITE_AZURE_POLICY_NAME=B2C_1_signupsignin
VITE_AZURE_DOMAIN=<your-tenant-name>.onmicrosoft.com
VITE_AZURE_INSTANCE=https://<your-tenant-name>.b2clogin.com
```

### Backend Configuration (`appsettings.json`)

```json
{
  "AzureAdB2C": {
    "Instance": "https://<your-tenant-name>.b2clogin.com",
    "Domain": "<your-tenant-name>.onmicrosoft.com", 
    "TenantId": "<your-tenant-id>",
    "ClientId": "<api-app-client-id>",
    "SignUpSignInPolicyId": "B2C_1_signupsignin"
  }
}
```

## Step 5: Test Authentication

1. **Run Both Applications**
   ```bash
   # Frontend
   cd src/web && npm run dev
   
   # Backend  
   cd src/api && dotnet run
   ```

2. **Test Sign-up Flow**
   - Navigate to frontend
   - Click sign-up/sign-in
   - Create a new account
   - Verify email functionality

3. **Test API Access**
   - Make authenticated requests to API
   - Verify JWT token validation

## Step 6: Customize (Optional)

### Custom Branding
1. Go to "Company branding" in B2C tenant
2. Upload logo and customize colors
3. Preview your changes

### Custom Policies (Advanced)
- For advanced scenarios, use custom policies
- Allows more control over user journey
- Requires XML policy configuration

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Ensure redirect URIs are correctly configured
   - Check CORS policy in API

2. **Token Validation Fails**
   - Verify tenant ID and client ID
   - Check policy name matches exactly

3. **User Flow Not Found**
   - Ensure policy name is correct (case-sensitive)
   - Verify policy is published

### Useful Resources

- [Azure AD B2C Documentation](https://docs.microsoft.com/en-us/azure/active-directory-b2c/)
- [MSAL.js Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-overview)
- [React MSAL Integration](https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-react)

## Security Best Practices

1. **Use HTTPS** in production
2. **Rotate secrets** regularly
3. **Monitor sign-ins** via Azure portal
4. **Enable MFA** for admin accounts
5. **Review permissions** periodically
6. **Use custom domains** for production

## Next Steps

After B2C setup:
1. Implement authentication in React frontend
2. Configure API authorization
3. Set up user profile management
4. Add social identity providers
5. Configure monitoring and alerts