class InstructionNotFound(Exception):
    """Documentation for InstructionNotFound

    """

    def __init__(self, reason):
        super().__init__(reason)


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
    command += ' '
    first_space = command.find(' ')
    mnemonic = command[:first_space]
    arguments = command[first_space:]
    list_of_arguments = arguments.split(',')
    command_list.append(mnemonic.strip())

    if arguments == ' ':
        return command_list

    for arg in list_of_arguments:
        command_list.append(arg.strip())
    return command_list


def catch_exception_of_instruction(instruction_list):
    """ Documentation for catch_exception_of_instruction """
    try:
        branch_instruction(instruction_list)
    except InstructionNotFound:
        print('Error occured: No such instruction found: ' +
              str(instruction_list))


def branch_instruction(parsed_instruction):
    """ Documentation for branch_instruction """
    command = parsed_instruction[0]
    if command == 'add':
        add_instruction(parsed_instruction[1:])
    else:
        raise InstructionNotFound('No Such command')


def add_instruction(args):
    """ Documentation for add_instruction """
    if len(args) != 2:
        raise InstructionNotFound('ADD is a 2 argument instruction')


def main():
    """ Documentation for main """
    assembly_command = input()
    parsed_code = parser(assembly_command)
    catch_exception_of_instruction(parsed_code)


if __name__ == '__main__':
    main()
