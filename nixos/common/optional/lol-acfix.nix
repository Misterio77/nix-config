{
  boot.kernel.sysctl = {
    # Disable VDSO on 32-bits to avoid league of legends kick
    "abi.vsyscall32" = 0;
  };
}
