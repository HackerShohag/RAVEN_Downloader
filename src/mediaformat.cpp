/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code is : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#include "mediaformat.h"

MediaFormat::MediaFormat()
{

}

QString MediaFormat::getFormatId() const
{
    return formatId;
}

void MediaFormat::setFormatId(const QString &value)
{
    formatId = value;
}

QString MediaFormat::getExtension() const
{
    return extension;
}

void MediaFormat::setExtension(const QString &value)
{
    extension = value;
}

QString MediaFormat::getResolution() const
{
    return resolution;
}

void MediaFormat::setResolution(const QString &value)
{
    resolution = value;
}

QString MediaFormat::getQuality() const
{
    return quality;
}

void MediaFormat::setQuality(const QString &value)
{
    quality = value;
}

QString MediaFormat::getNote() const
{
    return note;
}

void MediaFormat::setNote(const QString &value)
{
    note = value;
}

QString MediaFormat::getFormat() const
{
    return format;
}

void MediaFormat::setFormat(const QString &value)
{
    format = value;
}

QString MediaFormat::getAcodec() const
{
    return acodec;
}

void MediaFormat::setAcodec(const QString &value)
{
    acodec = value;
}

QString MediaFormat::getVcodec() const
{
    return vcodec;
}

void MediaFormat::setVcodec(const QString &value)
{
    vcodec = value;
}
