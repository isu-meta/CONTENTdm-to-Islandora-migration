"""To run this script, open Command Prompt, navigate to the directory
containing this script and type:
'python <script_name> <input_file_name> <output_file_name>',
replacing <script_name> with the name of this script, including the '.py' file extension,
<input_file_name> with the name of the Islandora-genrated XML file,
and <output_file_name> with a name of your choosing. Make sure that the Islandora
XML file is in the same directory as this script or that you include the full file
path to the XML file in place of <input_file_name>."""

# This is used to accept <input_file_name> and <output_file_name> from Command Prompt
import argparse

# Import functions from cdm_transformation_lib. You'll always want to 
# import 'ingest_xml' and 'save'. Additionally, you'll want to import
# which ever transformation functions you need for a given file. To import
# another function, add the function name (exclude the parentheses and 
# anything in the parantheses, so 'def add_typeOfResource(soup):' would be
# imported as 'add_typeOfResource'.) Seperate each function name from the
# preceeding one with a comma and space.
from cdm_transformation_lib import ingest_xml, save 


def main(in_file, out_file):
    """The main function. This opens the Islandora XML file, performs
    whatever transformations are specified and saves a new XML file."""
    soup = ingest_xml(in_file)

    # Insert your transformation functions here. They should follow the
    # basic format 'soup = function_name(arg)'. Make sure to match the
    # current indentation (4 spaces.)

    save(soup, out_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("in_file")
    parser.add_argument("out_file")

    args = parser.parse_args()

    main(args.in_file, args.out_file)