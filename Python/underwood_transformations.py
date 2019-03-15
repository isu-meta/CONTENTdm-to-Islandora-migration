"""To run this script, open Command Prompt, navigate to the directory
containing this script and type:
'python underwood_transformations.py <input_file_name> <output_file_name>',
replacing <input_file_name> with the name of the Islandora-genrated XML file
and <output_file_name> with a name of your choosing. Make sure that the Islandora
XML file is in the same directory as this script or that you include the full file
path to the XML file in place of <input_file_name>."""

import argparse

from cdm_transformation_lib import add_typeOfResource, ingest_xml, remove_extra_quotes, save, split_identifiers


def main(in_file, out_file):
    soup = ingest_xml(in_file)
    soup = split_identifiers(soup)
    soup = add_typeOfResource(soup)
    soup = remove_extra_quotes("title", soup)
    save(soup, out_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("in_file")
    parser.add_argument("out_file")

    args = parser.parse_args()

    main(args.in_file, args.out_file)

            