class Instruction:
    """Documentation for Instruction

    """

    def __init__(self, is64bit=True):
        self.legacy_prefix = None
        if is64bit:
            self.REX = {
                'prefix': 4,
                'W': False,
                'R': False,
                'X': False,
                'B': False
            }
        else:
            self.REX = None
        self.opcode = 0
        self.modrm = None
        self.sib = None
        self.displacement = None
        self.immediate = None

    def __str__(self):
        return '<Instuction>: '

    def __repr__(self):
        return str(self)


register_codes = {
    # ( REX.B , Reg Field )
    'rax': (0, 0),
    'rcx': (0, 1),
    'rdx': (0, 2),
    'rbx': (0, 3),
    'rsp': (0, 4),
    'rbp': (0, 5),
    'rsi': (0, 6),
    'rdi': (0, 7),
    'r8': (1, 0),
    'r9': (1, 1),
    'r10': (1, 2),
    'r11': (1, 3),
    'r12': (1, 4),
    'r13': (1, 5),
    'r14': (1, 6),
    'r15': (1, 7),
}


def parser(command):
    """ Documentation for parser """
    command_list = []
    command = command.strip().lower()
    first_space = command.find(' ')
    mnemonic = command[:first_space]
    arguments = command[first_space:]
    list_of_arguments = arguments.split(',')
    command_list.append(mnemonic.strip())
    for arg in list_of_arguments:
        command_list.append(arg.strip())
    return command_list


def main():
    """ Documentation for main """
    assembly_command = input()
    parsed_code = parser(assembly_command)


if __name__ == '__main__':
    main()
