# security.txt

The purpose of this module is to ease the generation of the file **security.txt** inside [Digital Experience Manager](https://www.jahia.com).
For more information about **security.txt**, please refer to this URL: https://securitytxt.org/

# Installation

- In DX, go to "Administration --> Server settings --> System components --> Modules"
- Upload the JAR **securitytxt-X.X.X.jar**
- Check that the module is started

# Use

## Administration

- Go to "Administration -> Server settings -> Web Projects"
- Edit the site with which you want to use this module and add it to the list of the deployed modules

## Edit mode

 * Go to "Edit mode -> Site settings -> Security.txt manager"
 * You can now define:
   * The security address: it will be used by people to communicate with you if they find a security issue
   * The PGP Key: a GPG/PGP public key that will be used to securely communicate with you. To generate it, please refer to this [section](#key-creation)
   * The security acknowledgements page: a page where you can thank the people having found a security issue
   * The security policy and/or disclosure policy page: a page where you explain the policy rules you're following, how the security issues have to be communicated, the perimeter of the bug bounty, etc
   * The external signature file: a GPG/PGP signature of the text file available at the address **DX_URL/.well-known/security.txt**. To generate it, please refer to this [section](#signature)

# GPG/PGP

## Key creation

- Generate a key:
```bash
gpg --full-generate-key
```
- Export your public key:
```bash
gpg --armor --export <EMAIL> > <EMAIL>.pub
```

## Signature

* Download the file **security.txt** on your computer thanks to the URL **DX_URL/.well-known/security.txt**
* Execute the following command to generate an external signature:
```bash
gpg --output security.txt.sig --detach-sig security.txt
```

## Check a signed document

* Execute the following command to check the validity of the signed document
```bash
gpg --output security.txt --decrypt security.txt.sig
```
