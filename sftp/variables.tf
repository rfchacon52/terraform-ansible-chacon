variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "172.16.0.0/16"
}
variable "region" {
  description = "Default EKS Region"
  type        = string
  default     = "us.east-1"
}

variable "sftp_host_private_key" {
  type      = string
  sensitive = true 
  
default = "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAuUKFa0H4JbxEVSFvh/cGFApQk+hGl0o63rnyZwIfHKw5vIg7
f/+JGxrFx1CKtY0MOrTVTt0og/M7E23JYHlrhIKYaf7W9fpIg2E4MQuTTtelU0Rz
03+FtGXCYxdnQAlIlp1J2X3lac8z68HwXRk8VMXKHeHIaPSBYHtBU+0nuwzJP66p
1CIIBJUkfMljENXKa67KroX0hSy1A9+PfXxJBatLvgjqkPRLIZFwY1enfnwDQVMn
L1raz2NWdz5YKzZvc1X9E4WUKasxmClT/WTC3lMCHtlHb88buB4orATCkQ2BIxVx
W2Z9ANbftthOwqeKjvzs7Ul6nKSiqN+/A0aS4wIDAQABAoIBABA6iI99xuwfUukW
Nbv2YrzsrmRWi6CDKycJqPdnEyyi1afzUysCSpNqQ/sSziPbSD/4SVtQOlVcwEcS
bfqaiFWiTxGx9kiz9Rg1MwPw3KWidGQX8gGMAT1tUJr3mN7eMVKoUqjPw4ICWa0E
Xzb4l/VhIjR9691t1cuK4I0mkD1tWg5DSRQ/2cJzmNP5jlc1H133Jgg5y5KSaEoJ
05MMFLhz4eOKmuxCtY98/tEjFhkoRl6WzWuxm0piKJPqo0ee4xaxHRHwXq6Xqo6O
++U831G/m4FnCEDqh15DsMCqHLyfkwkJoW1f3Ab5Kk48Bc4dRnLFM2IzJULDDLDO
1Mww9zECgYEA6jxu/k2aS9IzFW/TCmfukBqIntKLe+yGV79MsU1/agSB0Xx7m0yO
kMt0PhSIL+Ct1mSJ3JfIIRNUysjAYHVpbaYXEOGQziLf55OXmZrk3lY6/+4/V1Ke
FMkG8yRzB/3mlbLEke0sRTTIalTTw0GCXUBvGNtBWw45Wqun+eKUsNkCgYEAynki
LgVlcaBUcibxKN5CNqgUYSElx0iyuO2ddBCzK/IbmCh4MnePbc76FuDOst4iYpnv
mFZsd3jWXK3E3AHd1L0Mz/djScvUHJGtZi+hiNLghn4T0msaRdE2Mw+rLDSxexXa
xg7J6ybWFReJBk2u2b2DboSE6hhfFmjiFSsjzBsCgYAfOwOJgItMBLCu8QPwZT8X
k5IXqvbSBQ08cdMl6LFOT1+HsNNCN4jioV3UUSR/TbOf3DPNZ6dVUaCCkRWlRsJR
zk1RAOIvudKkq7cQ0egmBNVE/l0PpYJSPyNgE8IKlL3Dw9wVoMvARnNaSgkaBYf+
KvMlG0axf0oCXtS8qosssQKBgHUhWHWZJ5NxNgkHoDGNSm7GE2wROgKser/irljL
pGtC11XR657+bZoPx7ved5UgTnIOLX5KWNtQq2nYGO9RoRwF9diFfAngAag5Wj+o
RGGb5MnJO/xZe0xyeFFXuiWLojTbcsFrIsKHqAdxoxJjdEiAiv0vapjmWnPjXw7x
8vaLAoGAFj2/WPTcCDa3uFh9v+euKL/ixMACdw2XZkYQA5m5DwopHvKWs0U3eUx6
1UnI+cSGrLceN63NEj+YipAzD4tUwA07IDtZZhxMQ1I65iW2unyke8DeDL9pa8dz
O2sc7WF5rEtrQJTxox11BQtGfGw1XPQSKObuKIK6+oBNFBkZ+aI=
-----END RSA PRIVATE KEY-----"                      
}


